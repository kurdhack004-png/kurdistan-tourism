const { q } = require('./db');

async function initDb() {
  await q(`
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY, name TEXT NOT NULL, email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL, role TEXT DEFAULT 'user', banned BOOLEAN DEFAULT FALSE,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
    CREATE TABLE IF NOT EXISTS locations (
      id TEXT PRIMARY KEY, name TEXT NOT NULL, description TEXT DEFAULT '',
      category TEXT DEFAULT 'other', city TEXT DEFAULT '', lat DOUBLE PRECISION,
      lng DOUBLE PRECISION, rating DOUBLE PRECISION DEFAULT 0, image TEXT DEFAULT '',
      images JSONB DEFAULT '[]'::jsonb, verified BOOLEAN DEFAULT TRUE,
      name_ku TEXT DEFAULT '', name_ar TEXT DEFAULT '', description_ku TEXT DEFAULT '',
      description_ar TEXT DEFAULT '', video TEXT DEFAULT '', directions TEXT DEFAULT '',
      is_new BOOLEAN DEFAULT FALSE, is_featured BOOLEAN DEFAULT FALSE,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
    CREATE TABLE IF NOT EXISTS accommodations (
      id TEXT PRIMARY KEY, name TEXT NOT NULL, city TEXT DEFAULT '',
      type TEXT DEFAULT 'hotel', price DOUBLE PRECISION DEFAULT 0,
      rating DOUBLE PRECISION DEFAULT 0, image TEXT DEFAULT '', images JSONB DEFAULT '[]'::jsonb,
      description TEXT DEFAULT '', description_ku TEXT DEFAULT '', description_ar TEXT DEFAULT '',
      phone TEXT DEFAULT '', lat DOUBLE PRECISION, lng DOUBLE PRECISION,
      active BOOLEAN DEFAULT TRUE, listing_until TIMESTAMPTZ,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
    CREATE TABLE IF NOT EXISTS bookings (
      id TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      accommodation_id TEXT NOT NULL REFERENCES accommodations(id), date DATE NOT NULL,
      nights INTEGER NOT NULL DEFAULT 1, total DOUBLE PRECISION DEFAULT 0, guests INTEGER DEFAULT 1,
      status TEXT DEFAULT 'pending', payment_status TEXT DEFAULT 'unpaid',
      fee DOUBLE PRECISION DEFAULT 0, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
    CREATE TABLE IF NOT EXISTS reviews (
      id TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      location_id TEXT NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
      rating INTEGER NOT NULL, comment TEXT DEFAULT '', created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
    CREATE TABLE IF NOT EXISTS favorites (
      user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      location_id TEXT NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
      PRIMARY KEY(user_id, location_id)
    );
    CREATE TABLE IF NOT EXISTS settings (key TEXT PRIMARY KEY, value TEXT);
    CREATE TABLE IF NOT EXISTS ads (
      id TEXT PRIMARY KEY, title TEXT, company TEXT DEFAULT '', image TEXT DEFAULT '',
      link TEXT DEFAULT '', price DOUBLE PRECISION DEFAULT 0, starts_at TIMESTAMPTZ,
      ends_at TIMESTAMPTZ, active BOOLEAN DEFAULT TRUE, created_at TIMESTAMPTZ DEFAULT NOW()
    );
    CREATE TABLE IF NOT EXISTS hero_images (
      id TEXT PRIMARY KEY, image TEXT NOT NULL, sort_order INTEGER DEFAULT 0,
      active BOOLEAN DEFAULT TRUE, created_at TIMESTAMPTZ DEFAULT NOW()
    );
    CREATE TABLE IF NOT EXISTS emergency_contacts (
      id TEXT PRIMARY KEY, label TEXT, label_ku TEXT DEFAULT '', label_ar TEXT DEFAULT '',
      phone TEXT, sort_order INTEGER DEFAULT 0, created_at TIMESTAMPTZ DEFAULT NOW()
    );
    CREATE TABLE IF NOT EXISTS notifications (
      id TEXT PRIMARY KEY, title TEXT, body TEXT DEFAULT '', created_at TIMESTAMPTZ DEFAULT NOW()
    );
    CREATE TABLE IF NOT EXISTS listing_payments (
      id TEXT PRIMARY KEY, accommodation_id TEXT REFERENCES accommodations(id) ON DELETE CASCADE,
      amount DOUBLE PRECISION, months INTEGER DEFAULT 1, until TIMESTAMPTZ, created_at TIMESTAMPTZ DEFAULT NOW()
    );
    INSERT INTO settings(key,value) VALUES
      ('booking_fee','10000'),('listing_fee','30000'),('ad_price_24h','10000'),
      ('hero_interval_sec','5'),('currency','IQD')
    ON CONFLICT (key) DO NOTHING;
  `);

  const tourismLocations = [
    ['erbil-citadel','Erbil Citadel','قەڵای هەولێر','قلعة أربيل','historical','Erbil',36.1911,44.0092,'Historic citadel in the centre of Erbil and a UNESCO World Heritage site.','قەڵای مێژوویی ناوەندی هەولێر و شوێنێکی میراثی جیهانی یونسکۆیە.','قلعة تاريخية في مركز أربيل وموقع للتراث العالمي لليونسكو.'],
    ['qaysari-bazaar','Qaysari Bazaar','بازاڕی قەیسەری','سوق القيصرية','market','Erbil',36.18848,44.00924,'Traditional covered bazaar beside the Erbil Citadel.','بازاڕێکی نەریتی لە تەنیشت قەڵای هەولێر.','بازار تقليدي مسقوف بجانب قلعة أربيل.'],
    ['sami-abdulrahman-park','Sami Abdulrahman Park','پارکی سامی عەبدولڕەحمان','متنزه سامي عبد الرحمن','park','Erbil',36.19096,43.98321,'Large urban park with green areas, lakes and recreational facilities.','پارکێکی گەورەی شارستانی بە سەوزایی و دەریاچە و شوێنی پشوودان.','متنزه حضري كبير يضم مساحات خضراء وبحيرات ومرافق ترفيهية.'],
    ['mudhafaria-minaret','Mudhafaria Minaret','مینارەی مووزەفەری','منارة المظفرية','historical','Erbil',36.18753,43.9997,'Medieval brick minaret in Erbil associated with the Muzaffarid period.','مینارەیەکی مێژوویی لە هەولێر کە بە سەردەمی مووزەفەری پەیوەندیدارە.','مئذنة تاريخية من الطوب في أربيل تعود إلى العصر المظفري.'],
    ['shaqlawa','Shaqlawa','شەقڵاوە','شقلاوة','nature','Erbil',36.4,44.3368,'Mountain town known for its pleasant climate and surrounding valleys.','شارۆچکەیەکی شاخاوی بە ناوبانگ بۆ کەشوهەوا و دۆڵەکانی دەوروبەری.','بلدة جبلية معروفة بمناخها ووديانها المحيطة.'],
    ['rawanduz','Rawanduz','ڕەواندز','رواندوز','nature','Erbil',36.6146,44.5265,'Mountain town surrounded by dramatic gorges and highlands.','شارۆچکەیەکی شاخاوی لە نێوان گەڕەک و شاخە بەرزەکان.','بلدة جبلية تحيط بها الأخاديد والمرتفعات.'],
    ['gali-ali-beg-waterfall','Gali Ali Beg Waterfall','ئاویشارەی گەلی عەلی بەگ','شلال كلي علي بك','waterfall','Erbil',36.63145,44.44589,'Popular waterfall and natural attraction in the Rawanduz area.','ئاویشارێکی ناسراو و شوێنێکی سروشتی لە ناوچەی ڕەواندز.','شلال طبيعي شهير في منطقة رواندوز.'],
    ['korek-mountain','Korek Mountain','شاخی کۆڕەک','جبل كورك','mountain','Erbil',36.60835,44.49273,'Mountain destination known for panoramic views and recreation.','شوێنێکی شاخاوی بە دیمەنی پانۆرامی و چالاکییە گەشتیارییەکان.','وجهة جبلية معروفة بإطلالاتها والأنشطة الترفيهية.'],
    ['halgurd-mountain','Halgurd Mountain','شاخی هەڵگورد','جبل هلكورد','mountain','Erbil',36.7411,44.8614,'High Zagros mountain destination popular with hikers and nature visitors.','شاخێکی بەرزی زاگرۆس بۆ پیاسە و سروشتگەڕی.','وجهة جبلية عالية في زاغروس لمحبي المشي والطبيعة.'],
    ['shanidar-cave','Shanidar Cave','ئەشکەوتی شانەدەر','كهف شانيدر','archaeological','Erbil',36.8316,44.2211,'Important archaeological cave in the Baradost Mountains.','ئەشکەوتێکی گرنگی شوێنەواری لە شاخەکانی بارادۆست.','كهف أثري مهم في جبال برادوست.'],
    ['amedi','Amedi','ئامێدی','العمادية','historical','Duhok',37.092,43.4874,'Historic mountain town on a distinctive high plateau.','شارۆچکەیەکی مێژوویی شاخاوی لەسەر تەختاییەکی بەرز.','بلدة جبلية تاريخية على هضبة مرتفعة مميزة.'],
    ['lalish','Lalish','لالش','لالش','cultural','Duhok',36.7715,43.303,'Sacred cultural valley and major pilgrimage destination.','دۆڵێکی پیرۆز و شوێنێکی گرنگی زیارەت.','وادي مقدس ووجهة رئيسية للحج.'],
    ['duhok-dam','Duhok Dam','بەندی دهوک','سد دهوك','nature','Duhok',36.87581,43.00459,'Reservoir and scenic recreation area near Duhok.','دەریاچە و ناوچەیەکی جوانی سروشتی لە نزیک دهوک.','خزان ومنطقة ترفيهية ذات مناظر طبيعية قرب دهوك.'],
    ['zawa-mountain','Zawa Mountain','شاخی زاوا','جبل زاوا','mountain','Duhok',36.8375,42.95367,'Mountain viewpoint and recreational destination overlooking Duhok.','شوێنی دیمەن و پشوودان بە سەر دهوکەوە.','وجهة جبلية وإطلالة ترفيهية على دهوك.'],
    ['akre','Akre','ئاکرێ','عقرة','historical','Duhok',36.73049,43.87489,'Historic town in the northern Zagros foothills.','شارۆچکەیەکی مێژوویی لە پێدەشتی زاگرۆس.','بلدة تاريخية عند سفوح زاغروس الشمالية.'],
    ['delal-bridge','Delal Bridge','پردی دەلال','جسر دلال','historical','Duhok',37.13654,42.69457,'Historic stone bridge in the Zakho area.','پردێکی مێژوویی بەردین لە ناوچەی زاخۆ.','جسر حجري تاريخي في منطقة زاخو.'],
    ['dukan-lake','Dukan Lake','دەریاچەی دوکان','بحيرة دوكان','lake','Sulaymaniyah',36.0925,44.9358,'Large reservoir surrounded by mountains and rural landscapes.','دەریاچەیەکی گەورە لە نێوان شاخ و دیمەنی گوندنشینی.','بحيرة كبيرة تحيط بها الجبال والمناظر الريفية.'],
    ['sulaymaniyah','Sulaymaniyah','سلێمانی','السليمانية','city','Sulaymaniyah',35.564964,45.432905,'Major cultural city known for museums, markets and arts.','شاری سەرەکی کە بە مۆزەخانە و بازاڕ و هونەر ناسراوە.','مدينة ثقافية رئيسية تشتهر بالمتاحف والأسواق والفنون.'],
    ['amna-suraka-museum','Amna Suraka Museum','مۆزەخانەی ئەمنە سورەکە','متحف أمنه سوراكا','museum','Sulaymaniyah',35.56219,45.42545,'Museum and memorial complex in Sulaymaniyah.','مۆزەخانە و یادگارییەکی گرنگ لە سلێمانی.','متحف ومجمع تذكاري مهم في السليمانية.'],
    ['halabja','Halabja','هەڵەبجە','حلبجة','cultural','Halabja',35.1792,45.9874,'Historic city and memorial destination in the Kurdistan Region.','شارێکی مێژوویی و شوێنی یادەوەری لە هەرێمی کوردستان.','مدينة تاريخية ووجهة تذكارية في إقليم كردستان.']
  ];
  for (const [id,name,nameKu,nameAr,category,city,lat,lng,description,descriptionKu,descriptionAr] of tourismLocations) {
    await q(`INSERT INTO locations
      (id,name,description,category,city,lat,lng,rating,image,images,verified,name_ku,name_ar,description_ku,description_ar,is_new,is_featured)
      VALUES($1,$2,$3,$4,$5,$6,$7,0,'','[]'::jsonb,true,$8,$9,$10,$11,false,false)
      ON CONFLICT (id) DO UPDATE SET
        name=EXCLUDED.name,description=EXCLUDED.description,category=EXCLUDED.category,city=EXCLUDED.city,
        lat=EXCLUDED.lat,lng=EXCLUDED.lng,name_ku=EXCLUDED.name_ku,name_ar=EXCLUDED.name_ar,
        description_ku=EXCLUDED.description_ku,description_ar=EXCLUDED.description_ar,verified=true`,
      [id,name,description,category,city,lat,lng,nameKu,nameAr,descriptionKu,descriptionAr]);
  }

}
module.exports = { initDb };
