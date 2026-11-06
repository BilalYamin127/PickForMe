"""Apply the store logo to existing Android, iOS and web launcher icon sizes."""
from pathlib import Path
from PIL import Image
import json
root=Path(__file__).resolve().parents[2]
logo=Image.open(root/'store/source/logo-generated-master.png').convert('RGB')
for density,size in [('mdpi',48),('hdpi',72),('xhdpi',96),('xxhdpi',144),('xxxhdpi',192)]:
 logo.resize((size,size),Image.Resampling.LANCZOS).save(root/f'android/app/src/main/res/mipmap-{density}/ic_launcher.png')
icons=root/'ios/Runner/Assets.xcassets/AppIcon.appiconset'
for item in json.loads((icons/'Contents.json').read_text())['images']:
 if 'filename' in item:
  size=round(float(item['size'].split('x')[0])*float(item['scale'].rstrip('x')))
  logo.resize((size,size),Image.Resampling.LANCZOS).save(icons/item['filename'])
for path in (root/'web/icons').glob('*.png'):
 size=512 if '512' in path.name else 192
 logo.resize((size,size),Image.Resampling.LANCZOS).save(path)
logo.resize((32,32),Image.Resampling.LANCZOS).save(root/'web/favicon.png')
print('Updated Android, iOS and web launcher icon assets.')
