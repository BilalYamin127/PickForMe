"""Capture actual Flutter widgets with real fonts rather than test-runner Ahem blocks."""
import argparse, os, shutil, subprocess
from pathlib import Path
p=argparse.ArgumentParser()
p.add_argument('--flutter',default=shutil.which('flutter'))
p.add_argument('--emoji-font',default='/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf')
a=p.parse_args()
if not a.flutter:p.error('Provide --flutter /path/to/flutter/bin/flutter')
root=Path(__file__).resolve().parents[2]
flutter=Path(a.flutter).resolve()
fonts=flutter.parents[1]/'bin/cache/artifacts/material_fonts'
if not (fonts/'Roboto-Regular.ttf').exists():p.error('Flutter material fonts are missing; run flutter precache first')
backup={f:f.read_text() for f in (root/'lib').rglob('*.dart')}
fixture=root/'test/store_capture_generated_test.dart'
if fixture.exists():raise SystemExit('Temporary capture-test path already exists; move it before running')
env=os.environ.copy();env['PICKFORME_FLUTTER_FONTS']=str(fonts);env['PICKFORME_EMOJI_FONT']=a.emoji_font
try:
 # Only font families change during capture; default Android Roboto appearance
 # is made explicit for TextStyles that otherwise use Ahem in flutter test.
 for path,text in backup.items():
  text=text.replace('TextStyle(',"TextStyle(fontFamily: 'Roboto',fontFamilyFallback: const ['Noto Color Emoji'],")
  text=text.replace('return ThemeData(',"return ThemeData(fontFamily:'Roboto',fontFamilyFallback:const ['Noto Color Emoji'],")
  path.write_text(text)
 fixture.write_text((Path(__file__).parent/'capture_fixture.dart').read_text())
 (root/'store/raw-screenshots').mkdir(exist_ok=True,parents=True)
 subprocess.run([str(flutter),'test',str(fixture)],cwd=root,env=env,check=True)
finally:
 for path,text in backup.items():path.write_text(text)
 fixture.unlink(missing_ok=True)
