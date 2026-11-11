const puppeteer=require('puppeteer-core');
const {spawn}=require('child_process');
const [,,W,H,FPS,OUT,MODE]=process.argv; // MODE: video | stills
(async()=>{
 const b=await puppeteer.launch({executablePath:'/usr/bin/google-chrome',headless:'new',
  args:['--no-sandbox','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader','--ignore-gpu-blocklist',`--window-size=${W},${H}`]});
 const p=await b.newPage(); await p.setViewport({width:+W,height:+H,deviceScaleFactor:1});
 p.on('console',m=>console.log('PAGE',m.text())); p.on('pageerror',e=>console.log('ERR',e.message));
 await p.goto('file://'+require('path').resolve(__dirname,'views-storm.html')+'?capture=1');
 await p.waitForFunction('window.ready===true',{timeout:60000});
 const fps=+FPS, N=Math.round(30*fps);
 if(MODE==='stills'){
  const ts=(process.argv[7]||'0').split(',').map(Number);
  for(const t of ts){await p.evaluate((t)=>window.renderAt(t,Math.round(t*30)%900),t); await p.screenshot({path:`${OUT}_${t}.png`});}
  await b.close(); return;}
 const ff=spawn('ffmpeg',['-y','-loglevel','error','-f','image2pipe','-framerate',FPS,'-i','-','-c:v','libx264','-preset',process.env.PRESET||'slow','-crf',process.env.CRF||'20','-profile:v','high','-pix_fmt','yuv420p','-movflags','+faststart','-tag:v','avc1',OUT],{stdio:['pipe','inherit','inherit']});
 const t0=Date.now();
 for(let i=0;i<N;i++){
  await p.evaluate((t,f)=>window.renderAt(t,f),i/fps,i);
  const buf=await p.screenshot({type:'png',optimizeForSpeed:true});
  if(!ff.stdin.write(buf)) await new Promise(r=>ff.stdin.once('drain',r));
  if(i%60==0) console.log(OUT,i,'/',N,((Date.now()-t0)/1000).toFixed(0)+'s');
 }
 ff.stdin.end(); await new Promise(r=>ff.on('close',r)); await b.close();
})();
