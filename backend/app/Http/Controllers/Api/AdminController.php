<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Accommodation;
use App\Models\Ad;
use App\Models\Booking;
use App\Models\Location;
use App\Models\Review;
use App\Models\User;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    public function accommodations(Request $request)
    {
        return response()->json(['success'=>true,'data'=>Accommodation::with('owner:id,full_name,email')->latest()->paginate(50)]);
    }

    public function storeAccommodation(Request $request)
    {
        $data = $request->validate([
            'owner_id'=>['nullable','uuid','exists:users,id'],
            'type'=>['required','in:hotel,house,cabin,chalet,guesthouse,campsite,eco_lodge'],
            'name_ckb'=>['required','string','max:200'],'name_ar'=>['nullable','string','max:200'],'name_en'=>['nullable','string','max:200'],
            'description_ckb'=>['nullable','string'],'description_ar'=>['nullable','string'],'description_en'=>['nullable','string'],
            'city_ckb'=>['nullable','string','max:120'],'city_ar'=>['nullable','string','max:120'],'city_en'=>['nullable','string','max:120'],
            'price_per_night'=>['nullable','numeric','min:0'],'rating'=>['nullable','numeric','between:0,5'],'review_count'=>['nullable','integer','min:0'],
            'amenities'=>['nullable','array'],'latitude'=>['required','numeric','between:-90,90'],'longitude'=>['required','numeric','between:-180,180'],
            'is_active'=>['sometimes','boolean'],
        ]);
        $data['geom']=\Clickbar\Magellan\Data\Geometries\Point::make($data['latitude'],$data['longitude'],srid:4326);
        unset($data['latitude'],$data['longitude']);
        return response()->json(['success'=>true,'data'=>Accommodation::create($data)],201);
    }

    public function updateAccommodation(Request $request,string $id)
    {
        $item=Accommodation::findOrFail($id);
        $data=$request->validate([
            'type'=>['sometimes','in:hotel,house,cabin,chalet,guesthouse,campsite,eco_lodge'],
            'name_ckb'=>['sometimes','string','max:200'],'name_ar'=>['nullable','string','max:200'],'name_en'=>['nullable','string','max:200'],
            'description_ckb'=>['nullable','string'],'description_ar'=>['nullable','string'],'description_en'=>['nullable','string'],
            'city_ckb'=>['nullable','string','max:120'],'city_ar'=>['nullable','string','max:120'],'city_en'=>['nullable','string','max:120'],
            'price_per_night'=>['nullable','numeric','min:0'],'rating'=>['nullable','numeric','between:0,5'],'review_count'=>['nullable','integer','min:0'],
            'amenities'=>['nullable','array'],'latitude'=>['sometimes','numeric','between:-90,90'],'longitude'=>['sometimes','numeric','between:-180,180'],'is_active'=>['sometimes','boolean'],
        ]);
        if(isset($data['latitude'],$data['longitude'])) {
            $data['geom']=\Clickbar\Magellan\Data\Geometries\Point::make($data['latitude'],$data['longitude'],srid:4326);
            unset($data['latitude'],$data['longitude']);
        }
        $item->update($data);
        return response()->json(['success'=>true,'data'=>$item->fresh()]);
    }

    public function deleteAccommodation(string $id){ Accommodation::findOrFail($id)->delete(); return response()->json(['success'=>true]); }

    public function bookings(){ return response()->json(['success'=>true,'data'=>Booking::with(['user:id,full_name,email','accommodation'])->latest()->paginate(50)]); }
    public function updateBooking(Request $request,string $id){ $b=Booking::findOrFail($id); $d=$request->validate(['status'=>['required','in:pending,confirmed,cancelled,completed']]); $b->update($d); return response()->json(['success'=>true,'data'=>$b->fresh()]); }

    public function users(){ return response()->json(['success'=>true,'data'=>User::query()->latest()->paginate(50)]); }
    public function updateUser(Request $request,string $id){ $u=User::findOrFail($id); $d=$request->validate(['role'=>['sometimes','in:user,guide,admin,owner'],'is_active'=>['sometimes','boolean'],'preferred_lang'=>['sometimes','in:ckb,ar,en']]); $u->update($d); return response()->json(['success'=>true,'data'=>$u->fresh()]); }

    public function reviews(){ return response()->json(['success'=>true,'data'=>Review::with('user:id,full_name,email')->latest()->paginate(50)]); }
    public function deleteReview(string $id){ Review::findOrFail($id)->delete(); return response()->json(['success'=>true]); }

    public function ads(Request $request){ $q=Ad::query(); if($request->boolean('active_only')) $q->where('is_active',true)->where('starts_at','<=',now())->where('ends_at','>=',now()); return response()->json(['success'=>true,'data'=>$q->latest()->paginate(50)]); }
    public function storeAd(Request $request){
        $d=$request->validate(['title_ckb'=>['required','string','max:200'],'title_ar'=>['nullable','string','max:200'],'title_en'=>['nullable','string','max:200'],'description_ckb'=>['nullable','string'],'description_ar'=>['nullable','string'],'description_en'=>['nullable','string'],'target_url'=>['nullable','url','max:1000'],'starts_at'=>['required','date'],'ends_at'=>['required','date','after:starts_at'],'price_iqd'=>['nullable','numeric','min:10000']]);
        $d['created_by']=$request->user()->id; $d['price_iqd']=$d['price_iqd']??10000; $ad=Ad::create($d); return response()->json(['success'=>true,'data'=>$ad],201);
    }
    public function updateAd(Request $request,string $id){ $ad=Ad::findOrFail($id); $d=$request->validate(['title_ckb'=>['sometimes','string','max:200'],'title_ar'=>['nullable','string','max:200'],'title_en'=>['nullable','string','max:200'],'description_ckb'=>['nullable','string'],'description_ar'=>['nullable','string'],'description_en'=>['nullable','string'],'target_url'=>['nullable','url','max:1000'],'starts_at'=>['sometimes','date'],'ends_at'=>['sometimes','date','after:starts_at'],'price_iqd'=>['sometimes','numeric','min:10000'],'is_active'=>['sometimes','boolean']]); $ad->update($d); return response()->json(['success'=>true,'data'=>$ad->fresh()]); }
    public function uploadAdImage(Request $request,string $id)
    {
        $ad=Ad::findOrFail($id);
        $d=$request->validate(['image'=>['required','file','image','mimes:jpg,jpeg,png,webp','max:10240']]);
        $old=$ad->image_storage_key;
        $key=$d['image']->store('ads/'.$ad->id,'s3');
        $ad->update(['image_storage_key'=>$key]);
        if($old) Storage::disk('s3')->delete($old);
        return response()->json(['success'=>true,'data'=>$ad->fresh()]);
    }

    public function deleteAd(string $id){ 
        $ad=Ad::findOrFail($id);
        if($ad->image_storage_key) Storage::disk('s3')->delete($ad->image_storage_key);
        $ad->delete(); 
        return response()->json(['success'=>true]); 
    }

    public function uploadMedia(Request $request)
    {
        $d=$request->validate([
            'mediable_type'=>['required','in:location,accommodation'],'mediable_id'=>['required','uuid'],
            'media'=>['required','file','mimes:jpg,jpeg,png,webp,mp4,mov,webm','max:51200'],
            'caption'=>['nullable','string','max:255'],
        ]);
        $model=$d['mediable_type']==='location' ? Location::findOrFail($d['mediable_id']) : Accommodation::findOrFail($d['mediable_id']);
        $type=str_starts_with($d['media']->getMimeType(),'video/') ? 'video' : 'image';
        $key=$d['media']->store('media/'.$d['mediable_type'].'/'.$model->id,'s3');
        $media=Media::create(['mediable_type'=>$d['mediable_type'],'mediable_id'=>$model->id,'type'=>$type,'storage_key'=>$key,'caption'=>$d['caption']??null]);
        return response()->json(['success'=>true,'data'=>['id'=>$media->id,'type'=>$media->type,'caption'=>$media->caption,'url'=>$media->url()]],201);
    }

    public function deleteMedia(string $id)
    {
        $media=Media::findOrFail($id);
        Storage::disk('s3')->delete($media->storage_key);
        $media->delete();
        return response()->json(['success'=>true]);
    }

    public function locations(){ return response()->json(['success'=>true,'data'=>Location::with('media')->latest()->paginate(50)]); }

    public function storeLocation(Request $request)
    {
        $d=$request->validate([
            'category'=>['required','in:mountain,cave,lake,river,waterfall,spring,historical,archaeological,nature_reserve,other'],
            'governorate_id'=>['nullable','exists:governorates,id'],'district_id'=>['nullable','exists:districts,id'],
            'name_ckb'=>['required','string','max:200'],'name_ar'=>['nullable','string','max:200'],'name_en'=>['nullable','string','max:200'],
            'description_ckb'=>['nullable','string'],'description_ar'=>['nullable','string'],'description_en'=>['nullable','string'],
            'latitude'=>['required','numeric','between:-90,90'],'longitude'=>['required','numeric','between:-180,180'],
            'elevation_meters'=>['nullable','integer'],'is_verified'=>['sometimes','boolean'],
        ]);
        $d['geom']=Point::make($d['latitude'],$d['longitude'],srid:4326);
        unset($d['latitude'],$d['longitude']);
        $d['created_by']=$request->user()->id;
        return response()->json(['success'=>true,'data'=>Location::create($d)],201);
    }

    public function updateLocation(Request $request,string $id)
    {
        $item=Location::findOrFail($id);
        $d=$request->validate([
            'category'=>['sometimes','in:mountain,cave,lake,river,waterfall,spring,historical,archaeological,nature_reserve,other'],
            'governorate_id'=>['nullable','exists:governorates,id'],'district_id'=>['nullable','exists:districts,id'],
            'name_ckb'=>['sometimes','string','max:200'],'name_ar'=>['nullable','string','max:200'],'name_en'=>['nullable','string','max:200'],
            'description_ckb'=>['nullable','string'],'description_ar'=>['nullable','string'],'description_en'=>['nullable','string'],
            'latitude'=>['sometimes','numeric','between:-90,90'],'longitude'=>['sometimes','numeric','between:-180,180'],
            'elevation_meters'=>['nullable','integer'],'is_verified'=>['sometimes','boolean'],
        ]);
        if(isset($d['latitude'],$d['longitude'])) {
            $d['geom']=Point::make($d['latitude'],$d['longitude'],srid:4326);
            unset($d['latitude'],$d['longitude']);
        }
        $item->update($d);
        return response()->json(['success'=>true,'data'=>$item->fresh()->load('media')]);
    }

    public function deleteLocation(string $id){ Location::findOrFail($id)->delete(); return response()->json(['success'=>true]); }
}
