import base64
t=open('template.html').read()
p='data:image/jpeg;base64,'+base64.b64encode(open('assets/plate_2000.jpg','rb').read()).decode()
a='data:image/png;base64,'+base64.b64encode(open('assets/aux.png','rb').read()).decode()
open('views-storm.html','w').write(t.replace('__PLATE__',p).replace('__AUX__',a)); print('ok')
