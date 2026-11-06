"""Validate upload assets, build a SHA-256 manifest and create a portable ZIP."""
from pathlib import Path
from PIL import Image
import hashlib,json,zipfile
root=Path(__file__).resolve().parents[1]
checks=[(root/'branding/app-icon-512.png',(512,512)),(root/'branding/feature-graphic-1024x500.png',(1024,500))]
shots=sorted((root/'screenshots').glob('*.png'))
assert len(shots)==7,'Exactly seven upload screenshots are required'
checks.extend((p,(1080,1920)) for p in shots)
for path,size in checks:
 with Image.open(path) as image:
  assert image.size==size,(path,image.size)
  assert image.mode=='RGB',(path,image.mode)
  assert image.format=='PNG'
 assert path.stat().st_size<8*1024*1024,path
assert checks[0][0].stat().st_size<1024*1024
metadata=json.loads((root/'listing/metadata.json').read_text())
for key,limit in [('app_name',30),('short_description',80)]:assert len(metadata[key])<=limit
assert len((root/'listing/full-description.txt').read_text().strip())<=4000
# Exclude the archive itself and generated Python bytecode.
files=[p for p in sorted(root.rglob('*')) if p.is_file() and 'downloads' not in p.relative_to(root).parts and '__pycache__' not in p.parts and p.name!='manifest.json']
manifest={str(p.relative_to(root)):{'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in files}
(root/'manifest.json').write_text(json.dumps({'asset_count':len(files),'files':manifest},indent=2)+'\n')
files.append(root/'manifest.json')
(root/'downloads').mkdir(exist_ok=True)
archive=root/'downloads/PickForMe-store-kit.zip'
with zipfile.ZipFile(archive,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as z:
 for p in files:z.write(p,Path('PickForMe-store-kit')/p.relative_to(root))
print(f'Validated logo, feature graphic, 7 screenshots and listing limits. Packaged {len(files)} files: {archive.stat().st_size:,} bytes.')
