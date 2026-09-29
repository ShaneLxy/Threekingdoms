from PIL import Image, ImageDraw
from pathlib import Path
p=Path('assets/art/characters/ma_chao/sprites/attack_2')
files=sorted(p.glob('*.png'), key=lambda x:int(x.stem))
ims=[Image.open(f).convert('RGBA') for f in files]
scale=3
canvas=Image.new('RGBA',(max(im.width for im in ims)*scale*len(ims),max(im.height for im in ims)*scale),(40,40,40,255))
d=ImageDraw.Draw(canvas)
for i,im in enumerate(ims):
    canvas.alpha_composite(im.resize((im.width*scale,im.height*scale)),(i*im.width*scale,0))
    d.text((i*im.width*scale+4,4),files[i].stem,fill='white')
canvas.save('.tmp/ma_chao_attack2_inspect.png')
