import * as THREE from 'three';

const app = document.querySelector('#app');
const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(72, innerWidth / innerHeight, 0.1, 900);
const renderer = new THREE.WebGLRenderer({ antialias: false, powerPreference: 'high-performance' });
renderer.setPixelRatio(Math.min(devicePixelRatio, 1.5));
renderer.setSize(innerWidth, innerHeight);
renderer.outputColorSpace = THREE.SRGBColorSpace;
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.toneMappingExposure = 1.15;
app.prepend(renderer.domElement);

const world = new THREE.Group();
scene.add(world);
const clock = new THREE.Clock();
const raycaster = new THREE.Raycaster();
const keys = new Set();
let active = 'valley';
let yaw = 0;
let pitch = 0;
let joystickVector = new THREE.Vector2();
let lookPointer = null;
let lastX = 0;
let lastY = 0;

const palettes = {
  valley: { sky: 0x9ac8d0, fog: 0x9ac8d0, name: '山谷 · 云端入口', detail: '风从高地吹来，远处有一座通往海洋的光门。' },
  ocean: { sky: 0x061e3b, fog: 0x063b59, name: '深海 · 蓝色静域', detail: '微光浮游生物照亮海沟，前方有一座沉没遗迹。' },
  cosmos: { sky: 0x050812, fog: 0x10172d, name: '深空 · 星海边界', detail: '穿过陨石带，远方的行星正从星云中升起。' }
};

function mat(color, roughness = 0.88, extra = {}) { return new THREE.MeshStandardMaterial({ color, roughness, ...extra }); }
function addMesh(geometry, material, parent = world, x = 0, y = 0, z = 0) {
  const mesh = new THREE.Mesh(geometry, material); mesh.position.set(x, y, z); parent.add(mesh); return mesh;
}
function clearWorld() {
  while (world.children.length) {
    const child = world.children.pop();
    child.traverse?.(node => { node.geometry?.dispose(); if (Array.isArray(node.material)) node.material.forEach(m => m.dispose()); else node.material?.dispose(); });
  }
}
function seeded(i) { const x = Math.sin(i * 127.1 + 311.7) * 43758.5453; return x - Math.floor(x); }
function makeStars(count, spread, size, color, parent = world) {
  const points = new Float32Array(count * 3);
  for (let i = 0; i < count; i++) {
    const a = seeded(i + 2) * Math.PI * 2; const v = seeded(i + 500) * 2 - 1; const r = spread * (0.65 + seeded(i + 900) * 0.35);
    points[i * 3] = Math.cos(a) * Math.sqrt(1 - v * v) * r;
    points[i * 3 + 1] = v * r;
    points[i * 3 + 2] = Math.sin(a) * Math.sqrt(1 - v * v) * r;
  }
  const geo = new THREE.BufferGeometry(); geo.setAttribute('position', new THREE.BufferAttribute(points, 3));
  const stars = new THREE.Points(geo, new THREE.PointsMaterial({ color, size, sizeAttenuation: true, transparent: true, opacity: 0.9 })); parent.add(stars); return stars;
}
function buildValley() {
  scene.background = new THREE.Color(palettes.valley.sky); scene.fog = new THREE.FogExp2(palettes.valley.fog, 0.009);
  scene.add(new THREE.HemisphereLight(0xd7f4ff, 0x486052, 2.0));
  const sun = new THREE.DirectionalLight(0xffe6bf, 2.4); sun.position.set(-45, 75, 35); scene.add(sun);
  addMesh(new THREE.PlaneGeometry(500, 500, 1, 1), mat(0x5b816e), world, 0, -0.9, 0).rotation.x = -Math.PI / 2;
  const mountainMat = [mat(0x476b62), mat(0x587c70), mat(0x718f7c), mat(0x819887)];
  for (let i = 0; i < 44; i++) {
    const side = i % 2 ? 1 : -1; const z = -i * 10 - 18; const h = 13 + seeded(i + 80) * 34; const w = 14 + seeded(i + 180) * 25;
    const geo = new THREE.ConeGeometry(w, h, 5 + Math.floor(seeded(i + 300) * 3), 1);
    addMesh(geo, mountainMat[i % mountainMat.length], world, side * (20 + seeded(i + 20) * 28), h / 2 - 1, z).rotation.y = seeded(i + 400) * 0.8;
  }
  for (let i = 0; i < 34; i++) {
    const x = (seeded(i + 230) - 0.5) * 20; const z = -15 - i * 8;
    const tree = new THREE.Group(); tree.position.set(x, 0, z); world.add(tree);
    addMesh(new THREE.CylinderGeometry(0.16, 0.24, 2.4, 5), mat(0x5d493b), tree, 0, 1.1, 0);
    addMesh(new THREE.ConeGeometry(1.5, 4.5, 5), mat(i % 3 ? 0x28574b : 0x39705b), tree, 0, 3.7, 0);
  }
  addGate(-4, 1.9, -48, 0x61e8f5);
  addMesh(new THREE.SphereGeometry(5, 16, 12), mat(0xe5d6a1, .8, { emissive: 0x6c5530, emissiveIntensity: .18 }), world, 46, 15, -180);
}
function buildOcean() {
  scene.background = new THREE.Color(palettes.ocean.sky); scene.fog = new THREE.FogExp2(palettes.ocean.fog, 0.014);
  scene.add(new THREE.HemisphereLight(0x61d8f0, 0x03101b, 1.4));
  const beam = new THREE.DirectionalLight(0x54bfe3, 2.1); beam.position.set(-18, 45, -28); scene.add(beam);
  addMesh(new THREE.PlaneGeometry(500, 500), mat(0x082f45), world, 0, -1.2, 0).rotation.x = -Math.PI / 2;
  for (let i = 0; i < 90; i++) {
    const x = (seeded(i + 70) - .5) * 95; const z = -20 - seeded(i + 90) * 200; const h = 2 + seeded(i + 110) * 9;
    const coral = addMesh(new THREE.ConeGeometry(.35 + seeded(i + 130) * .6, h, 5), mat(i % 4 === 0 ? 0x2bd0c3 : i % 3 === 0 ? 0x337da0 : 0x1f6476, .45, { emissive: i % 4 === 0 ? 0x0c6768 : 0x061d27, emissiveIntensity: .28 }), world, x, h / 2 - .5, z);
    coral.rotation.z = (seeded(i + 150) - .5) * .35;
  }
  for (let i = 0; i < 18; i++) {
    const rock = addMesh(new THREE.DodecahedronGeometry(2 + seeded(i + 55) * 4, 0), mat(0x253f4d), world, (seeded(i + 56) - .5) * 66, 1, -35 - i * 8);
    rock.scale.y = .45;
  }
  const ruinMat = mat(0x566c6a, .92, { emissive: 0x071f22, emissiveIntensity: .25 });
  for (let i = 0; i < 5; i++) addMesh(new THREE.BoxGeometry(1.5, 10 - i * .6, 1.5), ruinMat, world, -12 + i * 6, 4, -92);
  addMesh(new THREE.BoxGeometry(36, 1.5, 4), ruinMat, world, 0, 8, -92);
  addGate(3, 2, -44, 0x39e6cc);
  const particles = makeStars(550, 150, .7, 0x62eddf); particles.position.y = 20;
}
function buildCosmos() {
  scene.background = new THREE.Color(palettes.cosmos.sky); scene.fog = new THREE.FogExp2(palettes.cosmos.fog, 0.0022);
  scene.add(new THREE.HemisphereLight(0x8ea7ff, 0x111226, .65));
  const key = new THREE.PointLight(0x88bfff, 90, 260); key.position.set(-35, 35, -75); scene.add(key);
  makeStars(1700, 360, .95, 0xcce9ff);
  const nebula = addMesh(new THREE.SphereGeometry(80, 18, 12), new THREE.MeshBasicMaterial({ color: 0x27345f, side: THREE.BackSide, transparent: true, opacity: .16 }), world, -70, 20, -180);
  nebula.scale.set(1.5, .4, .12); nebula.rotation.z = -.24;
  const planet = addMesh(new THREE.SphereGeometry(24, 24, 18), new THREE.MeshStandardMaterial({ color: 0x588eaa, roughness: .94, emissive: 0x132b4c, emissiveIntensity: .7 }), world, 50, 25, -205);
  const atmosphere = addMesh(new THREE.SphereGeometry(26, 20, 16), new THREE.MeshBasicMaterial({ color: 0x58c9ff, transparent: true, opacity: .13, side: THREE.BackSide }), world, 50, 25, -205);
  addMesh(new THREE.TorusGeometry(38, 1.5, 6, 64), new THREE.MeshBasicMaterial({ color: 0xe8bd87, transparent: true, opacity: .5 }), world, 50, 25, -205).rotation.x = 1.25;
  for (let i = 0; i < 28; i++) {
    const rock = addMesh(new THREE.IcosahedronGeometry(.6 + seeded(i + 600) * 2, 0), mat(i % 2 ? 0x6d6e7a : 0x4f5665), world, (seeded(i + 700) - .5) * 52, (seeded(i + 710) - .5) * 28, -25 - seeded(i + 720) * 110);
    rock.rotation.set(seeded(i + 730) * 3, seeded(i + 740) * 3, seeded(i + 750) * 3);
  }
  const blackHole = new THREE.Group(); blackHole.position.set(-40, 10, -145); world.add(blackHole);
  addMesh(new THREE.SphereGeometry(11, 24, 18), new THREE.MeshBasicMaterial({ color: 0x010207 }), blackHole);
  const ring = addMesh(new THREE.TorusGeometry(17, 2.2, 8, 80), new THREE.MeshBasicMaterial({ color: 0x85bfff, transparent: true, opacity: .8 }), blackHole); ring.rotation.x = 1.17; ring.scale.set(1.5, .7, 1);
  const ring2 = addMesh(new THREE.TorusGeometry(21, .65, 6, 80), new THREE.MeshBasicMaterial({ color: 0xff9d67, transparent: true, opacity: .72 }), blackHole); ring2.rotation.x = 1.17; ring2.scale.set(1.5, .7, 1);
  addGate(0, 1.5, -42, 0x93a9ff);
}
function addGate(x, y, z, color) {
  const group = new THREE.Group(); group.position.set(x, y, z); world.add(group);
  const glowing = new THREE.MeshBasicMaterial({ color, transparent: true, opacity: .92 });
  const ring = addMesh(new THREE.TorusGeometry(2.1, .12, 7, 32), glowing, group, 0, 0, 0); ring.scale.y = 1.55;
  addMesh(new THREE.PlaneGeometry(3.5, 5.2), new THREE.MeshBasicMaterial({ color, transparent: true, opacity: .13, side: THREE.DoubleSide, depthWrite: false }), group, 0, 0, -.04);
  addMesh(new THREE.CylinderGeometry(.07, .07, 4, 7), mat(0xd7fdff, .25, { emissive: color, emissiveIntensity: 1.4 }), group, -2.1, 0, 0);
  addMesh(new THREE.CylinderGeometry(.07, .07, 4, 7), mat(0xd7fdff, .25, { emissive: color, emissiveIntensity: 1.4 }), group, 2.1, 0, 0);
}
function setScene(name) {
  active = name; clearWorld();
  if (name === 'valley') buildValley(); else if (name === 'ocean') buildOcean(); else buildCosmos();
  const p = palettes[name]; document.querySelector('#scene-name').textContent = p.name; document.querySelector('#scene-detail').textContent = p.detail;
  document.querySelectorAll('[data-scene]').forEach(button => button.classList.toggle('active', button.dataset.scene === name));
  camera.position.set(0, name === 'cosmos' ? 2 : 1.8, 8); yaw = 0; pitch = 0; camera.rotation.set(0, 0, 0);
}
document.querySelectorAll('[data-scene]').forEach(button => button.addEventListener('click', () => setScene(button.dataset.scene)));
setScene('valley');

function onResize() { camera.aspect = innerWidth / innerHeight; camera.updateProjectionMatrix(); renderer.setPixelRatio(Math.min(devicePixelRatio, innerWidth < 700 ? 1.25 : 1.5)); renderer.setSize(innerWidth, innerHeight); }
addEventListener('resize', onResize);
addEventListener('keydown', e => { keys.add(e.code); if (e.code === 'Space') e.preventDefault(); });
addEventListener('keyup', e => keys.delete(e.code));
renderer.domElement.addEventListener('click', () => { if (innerWidth > 700 && document.pointerLockElement !== renderer.domElement) renderer.domElement.requestPointerLock?.(); });
addEventListener('mousemove', e => { if (document.pointerLockElement === renderer.domElement) { yaw -= e.movementX * .0022; pitch -= e.movementY * .0022; } });
renderer.domElement.addEventListener('pointerdown', e => { if (innerWidth <= 700 && e.clientX > innerWidth * .38) { lookPointer = e.pointerId; lastX = e.clientX; lastY = e.clientY; renderer.domElement.setPointerCapture(e.pointerId); } });
renderer.domElement.addEventListener('pointermove', e => { if (e.pointerId === lookPointer) { yaw -= (e.clientX - lastX) * .004; pitch -= (e.clientY - lastY) * .004; lastX = e.clientX; lastY = e.clientY; } });
renderer.domElement.addEventListener('pointerup', e => { if (e.pointerId === lookPointer) lookPointer = null; });
const joystick = document.querySelector('#joystick'); const stick = document.querySelector('#stick'); let joyPointer = null;
joystick.addEventListener('pointerdown', e => { joyPointer = e.pointerId; joystick.setPointerCapture(e.pointerId); updateJoy(e); });
joystick.addEventListener('pointermove', e => { if (e.pointerId === joyPointer) updateJoy(e); });
function updateJoy(e) { const r = joystick.getBoundingClientRect(); const dx = e.clientX - (r.left + r.width / 2); const dy = e.clientY - (r.top + r.height / 2); const len = Math.min(34, Math.hypot(dx, dy)); const a = Math.atan2(dy, dx); const x = Math.cos(a) * len; const y = Math.sin(a) * len; stick.style.transform = `translate(${x}px, ${y}px)`; joystickVector.set(x / 34, -y / 34); }
function resetJoy(e) { if (e.pointerId === joyPointer) { joyPointer = null; joystickVector.set(0, 0); stick.style.transform = ''; } }
joystick.addEventListener('pointerup', resetJoy); joystick.addEventListener('pointercancel', resetJoy);

const forward = new THREE.Vector3(); const right = new THREE.Vector3();
function animate() {
  requestAnimationFrame(animate);
  const dt = Math.min(clock.getDelta(), .04);
  pitch = THREE.MathUtils.clamp(pitch, -1.15, 1.15);
  camera.rotation.order = 'YXZ'; camera.rotation.set(pitch, yaw, 0);
  const f = (keys.has('KeyW') || keys.has('ArrowUp') ? 1 : 0) - (keys.has('KeyS') || keys.has('ArrowDown') ? 1 : 0) + joystickVector.y;
  const s = (keys.has('KeyD') || keys.has('ArrowRight') ? 1 : 0) - (keys.has('KeyA') || keys.has('ArrowLeft') ? 1 : 0) + joystickVector.x;
  forward.set(-Math.sin(yaw), 0, -Math.cos(yaw)); right.set(Math.cos(yaw), 0, -Math.sin(yaw));
  const speed = (keys.has('ShiftLeft') ? 24 : 12) * dt;
  camera.position.addScaledVector(forward, f * speed); camera.position.addScaledVector(right, s * speed);
  const vertical = (keys.has('Space') ? 1 : 0) - (keys.has('ControlLeft') ? 1 : 0);
  camera.position.y += vertical * speed;
  if (active !== 'cosmos') camera.position.y = Math.max(.7, Math.min(camera.position.y, 24));
  if (active === 'cosmos') camera.position.y = Math.max(-20, Math.min(camera.position.y, 45));
  world.children.forEach(child => { if (child.type === 'Points') child.rotation.y += dt * .004; });
  renderer.render(scene, camera);
}
animate();
