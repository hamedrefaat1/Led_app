import 'dart:io';

import 'package:image_picker/image_picker.dart';

class Imagepickerr {
  Future<File> upLoadImage(String inputSource) async {
    final picker = ImagePicker();
    final XFile? pickerImage = await picker.pickImage(
        source:
            inputSource == "camera" ? ImageSource.camera : ImageSource.gallery);
    File imageFile = File(pickerImage!.path);

    return imageFile;
  }
}
 