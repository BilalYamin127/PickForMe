from PIL import Image,ImageDraw,ImageFont,ImageFilter
from pathlib import Path
import math, json, shutil, os
ROOT=Path(__file__).resolve().parents[1]
FONTS=Path(os.environ.get('PICKFORME_FONT_DIR','/usr/share/fonts/truetype/dejavu'))
def font(n,bold=False):return ImageFont.truetype(str(FONTS/('DejaVuSans-Bold.ttf' if bold else 'DejaVuSans.ttf')),n)
SOURCE=ROOT/'source'/'logo-generated-master.png'

logo=Image.open(SOURCE).convert('RGB')
for size in [512,1024]:logo.resize((size,size),Image.Resampling.LANCZOS).save(ROOT/'branding'/f'app-icon-{size}.png',optimize=True)
def gradient(w,h,phase=0):
 im=Image.new('RGB',(w,h));pixels=im.load()
 for y in range(h):
  for x in range(w):
   t=y/h;g=math.exp(-(((x/w-.88)/.75)**2+((y/h-.35)/.6)**2)*3)
   mint=math.exp(-(((x/w-.05)/.7)**2+((y/h-.85)/.45)**2)*4)
   pixels[x,y]=(int(22+13*t+26*g),int(16+7*t+13*g+10*mint),int(43+17*t+48*g+14*mint))
 return im

def rounded_image(im,size,radius):
 out=im.resize(size,Image.Resampling.LANCZOS).convert('RGBA');m=Image.new('L',size);ImageDraw.Draw(m).rounded_rectangle((0,0,*size),radius=radius,fill=255);out.putalpha(m);return out

def sparkle(d,x,y,r,color):
 points=[(x,y-r),(x+r*.25,y-r*.25),(x+r,y),(x+r*.25,y+r*.25),(x,y+r),(x-r*.25,y+r*.25),(x-r,y),(x-r*.25,y-r*.25)]
 d.polygon(points,fill=color)

def brand(im,x,y,size=46):
 im.paste(rounded_image(logo,(size,size),size//4),(x,y),rounded_image(logo,(size,size),size//4))
 ImageDraw.Draw(im).text((x+size+14,y+5),'PickForMe',font=font(int(size*.65),True),fill='#f5efff')

# Play feature graphic: native 1024 x 500, opaque RGB, safe margins.
im=gradient(1024,500);d=ImageDraw.Draw(im)
# understated orbital lines for depth
for r in [204,239,278]:d.ellipse((795-r,255-r,795+r,255+r),outline='#4b3474',width=1)
brand(im,62,46,44)
d.text((62,127),'Less deciding.',font=font(49,True),fill='#ffffff')
d.text((62,190),'More doing.',font=font(49,True),fill='#cab4ff')
d.text((65,274),'Spin a wheel. Find your next yes.',font=font(21),fill='#d8cde9')
for x,w,label in [(64,146,'SPIN WHEEL'),(222,153,'SHUFFLE LIST'),(387,103,'OFFLINE')]:
 d.rounded_rectangle((x,344,x+w,382),radius=19,fill='#36254e',outline='#665082')
 d.text((x+w/2,363),label,font=font(12,True),fill='#eee6ff',anchor='mm')
# Logo focal point, no unsupported marketing claims.
lo=rounded_image(logo,(354,354),70);im.paste(lo,(620,74),lo)
sparkle(d,587,87,15,'#efb9d2');sparkle(d,966,439,13,'#9ae1cf');d.ellipse((571,406,581,416),fill='#eab15e')
im.save(ROOT/'branding'/'feature-graphic-1024x500.png',optimize=True)
# 7 screenshot posters composed around unmodified native Flutter screen captures.
POSTERS=[
('01-home','Less deciding.','More living.','A little chance for your everyday choices.','#cdb8ff'),
('02-create','Your question.','Your possibilities.','Add, edit and reorder the options.','#f2b5cf'),
('03-wheel','Give chance','a turn.','Every option gets an equal shot.','#b5e6d9'),
('04-shuffle','Another way','to find your yes.','Switch it up with the shuffle picker.','#b5d8f6'),
('05-result','And just like that,','it’s decided.','Reveal your pick. Share the moment.','#f3c68b'),
('06-saved-lists','Good choices.','Ready for next time.','Save your favorites. Spin them again.','#cfb9fa'),
('07-dark-settings','Your vibe.','Day or night.','Dark mode, sound and haptics—your way.','#addecf'),
]
for i,(slug,line1,line2,sub,accent) in enumerate(POSTERS):
 im=gradient(1080,1920,i);d=ImageDraw.Draw(im);brand(im,66,44,46)
 d.text((68,139),line1,font=font(72,True),fill='white')
 # Fit long headings into the same editorial grid.
 size=72
 while d.textlength(line2,font=font(size,True))>950:size-=1
 d.text((68,229),line2,font=font(size,True),fill=accent)
 d.text((71,339),sub,font=font(26),fill='#ded4ec')
 sparkle(d,983,84,16,accent)
 # Real capture in a subtle device frame. No added controls or fabricated app UI.
 screen=Image.open(ROOT/'raw-screenshots'/f'{slug}.png').convert('RGB')
 sw=650;sh=round(sw*screen.height/screen.width);x=(1080-sw)//2;y=446
 shadow=Image.new('RGBA',im.size);sd=ImageDraw.Draw(shadow);sd.rounded_rectangle((x-24,y-8,x+sw+24,y+sh+42),radius=64,fill=(0,0,0,160));shadow=shadow.filter(ImageFilter.GaussianBlur(28));im=Image.alpha_composite(im.convert('RGBA'),shadow)
 d=ImageDraw.Draw(im);d.rounded_rectangle((x-15,y-15,x+sw+15,y+sh+15),radius=49,fill='#15121c',outline='#78658e',width=2)
 scr=rounded_image(screen,(sw,sh),36);im.alpha_composite(scr,(x,y))
 d=ImageDraw.Draw(im);d.text((71,1869),'PICKFORME  /  RANDOM DECISION MAKER',font=font(15,True),fill='#bdacca')
 d.text((1007,1869),f'{i+1:02d} / 07',font=font(15),fill=accent,anchor='ra')
 im.convert('RGB').save(ROOT/'screenshots'/f'{slug}-1080x1920.png',optimize=True)
# Overview for remote review, deliberately outside the screenshot upload folder.
thumbs=[]
for slug,*_ in POSTERS:
 t=Image.open(ROOT/'screenshots'/f'{slug}-1080x1920.png');t.thumbnail((270,480));thumbs.append(t)
sheet=Image.new('RGB',(4*290+20,2*500+20),'#eee9f5')
for i,t in enumerate(thumbs):sheet.paste(t,(20+(i%4)*290,20+(i//4)*500))
sheet.save(ROOT/'asset-overview.jpg',quality=95)
# Editable vector wordmark; production raster logo is also supplied separately.
svg='''<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="240" viewBox="0 0 1000 240"><rect width="1000" height="240" rx="40" fill="#211334"/><g transform="translate(120 120)"><circle r="76" fill="#7958d6"/><path d="M0 0V-76A76 76 0 0 1 65.8 -38Z" fill="#ed78a1"/><path d="M0 0L65.8 -38A76 76 0 0 1 65.8 38Z" fill="#efb659"/><path d="M0 0L65.8 38A76 76 0 0 1 0 76Z" fill="#63c8ad"/><path d="M0 0V76A76 76 0 0 1 -65.8 38Z" fill="#65b4ec"/><path d="M0 0L-65.8 38A76 76 0 0 1 -65.8 -38Z" fill="#ba91f0"/><circle r="22" fill="white"/><path d="M0 -13Q2 -2 13 0Q2 2 0 13Q-2 2 -13 0Q-2 -2 0 -13" fill="#5b32a8"/><path d="M-15 -93H15L0 -63Z" fill="white"/></g><text x="231" y="124" fill="#ffffff" font-family="DejaVu Sans,Arial,sans-serif" font-size="76" font-weight="700" letter-spacing="-3">PickForMe</text><text x="237" y="169" fill="#cfb9f5" font-family="DejaVu Sans,Arial,sans-serif" font-size="22" letter-spacing="3">A LITTLE LESS OVERTHINKING.</text></svg>'''
(ROOT/'branding'/'wordmark-editable.svg').write_text(svg)
print('Created icon exports, feature graphic, 7 screenshots and overview.')
