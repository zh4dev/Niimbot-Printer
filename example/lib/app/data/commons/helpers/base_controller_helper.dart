import 'package:get/get.dart';

class BaseControllerHelper extends GetxController  {

  final loadingStatus = false.obs;

  void setBusy(){
    loadingStatus.value = true;
  }

  void setIdle(){
    loadingStatus.value = false;
  }

  void setError(){
    loadingStatus.addError('error');
  }

  @override
  void onClose() {
    loadingStatus.close();
    super.onClose();
  }
}