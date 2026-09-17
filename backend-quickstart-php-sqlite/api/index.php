<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(204); exit; }

$dbFile = __DIR__ . '/data.sqlite';
$pdo = new PDO('sqlite:' . $dbFile, null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC]);
$pdo->exec('PRAGMA foreign_keys = ON');
$pdo->exec("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT,email TEXT UNIQUE NOT NULL,password_hash TEXT NOT NULL,name TEXT NOT NULL,token TEXT,created_at TEXT NOT NULL)");
$pdo->exec("CREATE TABLE IF NOT EXISTS locations (id INTEGER PRIMARY KEY AUTOINCREMENT,name_ckb TEXT NOT NULL,name_ar TEXT NOT NULL,name_en TEXT NOT NULL,type TEXT NOT NULL,governorate TEXT NOT NULL,description TEXT NOT NULL,lat REAL NOT NULL,lng REAL NOT NULL,image TEXT DEFAULT '')");
$pdo->exec("CREATE TABLE IF NOT EXISTS bookings (id INTEGER PRIMARY KEY AUTOINCREMENT,user_id INTEGER NOT NULL,place_id INTEGER NOT NULL,date TEXT NOT NULL,guests INTEGER NOT NULL,status TEXT NOT NULL DEFAULT 'pending',created_at TEXT NOT NULL,FOREIGN KEY(user_id) REFERENCES users(id),FOREIGN KEY(place_id) REFERENCES locations(id))");
$count=(int)$pdo->query('SELECT COUNT(*) FROM locations')->fetchColumn();
if($count===0){$rows=[
['شەقڵاوە','شقلاوة','Shaqlawa','Mountain','Erbil','شارێکی گەشتیاری لە نێوان چیاکان، بە کەش و هەوای خۆش و سروشتی جوان.',36.4049,44.3253],
['ڕەواندز','راوندوز','Rawanduz','Mountain','Erbil','ناوچەیەکی ناسراو بە دۆڵ و کانی و ڕێگاکانی سروشتی.',36.6183,44.5353],
['دەریاچەی دوکان','بحيرة دوكان','Dukan Lake','Water','Sulaymaniyah','یەکێک لە گرنگترین شوێنە ئاوییە گەشتیارییەکانی کوردستان.',35.9465,44.9542],
['شلالی بەخاڵ','شلال بيخال','Bekhal Waterfall','Water','Erbil','شوێنێکی بەناوبانگ بۆ سەیران و پیکنیک.',36.6308,44.4486],
['هەڵگورد','هلكورد','Halgurd','Mountain','Erbil','یەکێک لە بەرزترین چیاکانی کوردستان، گونجاو بۆ trekking.',36.735,44.912],
['کۆیەی کۆن','كوية القديمة','Old Koy Sanjaq','History','Erbil','شوێنێکی مێژوویی بۆ ناسینی مێژوو و کەلتووری ناوچەکە.',36.080,44.628]
];$st=$pdo->prepare('INSERT INTO locations(name_ckb,name_ar,name_en,type,governorate,description,lat,lng) VALUES(?,?,?,?,?,?,?,?)');foreach($rows as $r)$st->execute($r);}
function out($data,int $status=200): never { http_response_code($status); echo json_encode($data,JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES); exit; }
function body(): array { $raw=file_get_contents('php://input'); $j=json_decode($raw ?: '{}',true); return is_array($j)?$j:[]; }
function bearer(): ?string { $h=$_SERVER['HTTP_AUTHORIZATION']??''; return preg_match('/Bearer\s+(.+)/i',$h,$m)?trim($m[1]):null; }
function user(PDO $pdo): ?array { $t=bearer(); if(!$t)return null; $s=$pdo->prepare('SELECT * FROM users WHERE token=?');$s->execute([$t]);return $s->fetch()?:null; }
$path=parse_url($_SERVER['REQUEST_URI'],PHP_URL_PATH); $base=rtrim(dirname($_SERVER['SCRIPT_NAME']),'/'); if($base && str_starts_with($path,$base))$path=substr($path,strlen($base)); $path=$path?:'/'; $method=$_SERVER['REQUEST_METHOD'];
if($method==='GET'&&$path==='/health')out(['success'=>true,'status'=>'online','version'=>'11.0']);
if($method==='GET'&&$path==='/locations'){$q=trim((string)($_GET['q']??''));if($q){$s=$pdo->prepare("SELECT * FROM locations WHERE name_ckb LIKE ? OR name_ar LIKE ? OR name_en LIKE ? OR governorate LIKE ? ORDER BY id DESC");$like='%'.$q.'%';$s->execute([$like,$like,$like,$like]);}else{$s=$pdo->query('SELECT * FROM locations ORDER BY id DESC');}out(['success'=>true,'data'=>$s->fetchAll()]);}
if($method==='GET'&&preg_match('#^/locations/(\d+)$#',$path,$m)){$s=$pdo->prepare('SELECT * FROM locations WHERE id=?');$s->execute([(int)$m[1]]);$x=$s->fetch();if(!$x)out(['success'=>false,'message'=>'Not found'],404);out(['success'=>true,'data'=>$x]);}
if($method==='POST'&&$path==='/auth/register'){$b=body();$email=strtolower(trim((string)($b['email']??'')));$pass=(string)($b['password']??'');$name=trim((string)($b['name']??'Tourist'));if(!filter_var($email,FILTER_VALIDATE_EMAIL)||strlen($pass)<6)out(['success'=>false,'message'=>'Valid email and password >= 6 required'],422);try{$token=bin2hex(random_bytes(32));$s=$pdo->prepare('INSERT INTO users(email,password_hash,name,token,created_at) VALUES(?,?,?,?,?)');$s->execute([$email,password_hash($pass,PASSWORD_DEFAULT),$name,$token,date('c')]);out(['success'=>true,'token'=>$token,'user'=>['id'=>(int)$pdo->lastInsertId(),'email'=>$email,'name'=>$name]],201);}catch(PDOException $e){out(['success'=>false,'message'=>'Email already registered'],409);}}
if($method==='POST'&&$path==='/auth/login'){$b=body();$email=strtolower(trim((string)($b['email']??'')));$pass=(string)($b['password']??'');$s=$pdo->prepare('SELECT * FROM users WHERE email=?');$s->execute([$email]);$u=$s->fetch();if(!$u||!password_verify($pass,$u['password_hash']))out(['success'=>false,'message'=>'Invalid credentials'],401);$token=bin2hex(random_bytes(32));$pdo->prepare('UPDATE users SET token=? WHERE id=?')->execute([$token,$u['id']]);out(['success'=>true,'token'=>$token,'user'=>['id'=>(int)$u['id'],'email'=>$u['email'],'name'=>$u['name']]]);}
if($method==='POST'&&$path==='/auth/logout'){if($u=user($pdo))$pdo->prepare('UPDATE users SET token=NULL WHERE id=?')->execute([$u['id']]);out(['success'=>true]);}
if($method==='GET'&&$path==='/auth/me'){if(!$u=user($pdo))out(['success'=>false,'message'=>'Unauthorized'],401);out(['success'=>true,'user'=>['id'=>(int)$u['id'],'email'=>$u['email'],'name'=>$u['name']]]);}
if($method==='POST'&&$path==='/bookings'){if(!$u=user($pdo))out(['success'=>false,'message'=>'Unauthorized'],401);$b=body();$pid=(int)($b['place_id']??0);$date=trim((string)($b['date']??''));$guests=max(1,(int)($b['guests']??1));$s=$pdo->prepare('SELECT id FROM locations WHERE id=?');$s->execute([$pid]);if(!$s->fetch())out(['success'=>false,'message'=>'Place not found'],404);$pdo->prepare('INSERT INTO bookings(user_id,place_id,date,guests,status,created_at) VALUES(?,?,?,?,?,?)')->execute([$u['id'],$pid,$date,$guests,'pending',date('c')]);out(['success'=>true,'id'=>(int)$pdo->lastInsertId()],201);}
if($method==='GET'&&$path==='/bookings'){if(!$u=user($pdo))out(['success'=>false,'message'=>'Unauthorized'],401);$s=$pdo->prepare('SELECT b.*,l.name_ckb,l.name_ar,l.name_en FROM bookings b JOIN locations l ON l.id=b.place_id WHERE b.user_id=? ORDER BY b.id DESC');$s->execute([$u['id']]);out(['success'=>true,'data'=>$s->fetchAll()]);}
out(['success'=>false,'message'=>'Route not found'],404);
