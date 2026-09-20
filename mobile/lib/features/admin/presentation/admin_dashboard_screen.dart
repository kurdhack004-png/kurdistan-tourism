import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});
  @override ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}
class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  bool _loading = true; String? _error; final Map<String,int> _counts = {};
  @override void initState(){ super.initState(); Future.microtask(_load); }
  Future<void> _load() async {
    final auth=ref.read(authProvider);
    if(!auth.isAuthenticated || auth.role!='admin'){ if(mounted)setState((){_loading=false;_error='admin_only'.tr();}); return; }
    if(mounted)setState((){_loading=true;_error=null;});
    final api=ref.read(apiClientProvider);
    const endpoints={'admin_places':'/admin/locations','admin_accommodations':'/admin/accommodations','admin_bookings':'/admin/bookings','admin_users':'/admin/users','admin_reviews':'/admin/reviews','admin_ads':'/admin/ads'};
    try { for(final e in endpoints.entries){ final res=await api.client.get(e.value); final body=Map<String,dynamic>.from(res.data as Map); final data=body['data']; if(data is Map && data['total'] is num){_counts[e.key]=(data['total'] as num).toInt();} else if(data is List){_counts[e.key]=data.length;} } }
    on DioException catch(e){ final data=e.response?.data; _error=data is Map && data['message'] is String ? data['message'] as String : 'admin_load_failed'.tr(); }
    catch(_){_error='admin_load_failed'.tr();}
    finally{if(mounted)setState(()=>_loading=false);}
  }
  @override Widget build(BuildContext context){
    final cards=[['admin_places'.tr(),Icons.place_outlined,'admin_places'],['admin_accommodations'.tr(),Icons.hotel_outlined,'admin_accommodations'],['admin_bookings'.tr(),Icons.calendar_month_outlined,'admin_bookings'],['admin_users'.tr(),Icons.people_outline,'admin_users'],['admin_reviews'.tr(),Icons.rate_review_outlined,'admin_reviews'],['admin_ads'.tr(),Icons.campaign_outlined,'admin_ads']];
    return Scaffold(appBar:AppBar(title:Text('admin_panel'.tr()),actions:[IconButton(onPressed:_loading?null:_load,icon:const Icon(Icons.refresh_rounded))]),body:RefreshIndicator(onRefresh:_load,child:ListView(padding:const EdgeInsets.all(AppSpacing.lg),children:[Text('admin_dashboard'.tr(),style:Theme.of(context).textTheme.headlineSmall),const SizedBox(height:8),Text('admin_dashboard_hint'.tr()),const SizedBox(height:20),if(_loading)const LinearProgressIndicator(),if(_error!=null)Padding(padding:const EdgeInsets.symmetric(vertical:12),child:Text(_error!,style:TextStyle(color:Theme.of(context).colorScheme.error))),GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:cards.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:12,mainAxisSpacing:12,childAspectRatio:1.35),itemBuilder:(_,i){final c=cards[i];return Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(c[1] as IconData),const Spacer(),Text(c[0] as String,maxLines:2,overflow:TextOverflow.ellipsis),const SizedBox(height:4),Text((_counts[c[2] as String]??0).toString(),style:Theme.of(context).textTheme.headlineMedium)])));})])));
  }
}
