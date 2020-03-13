
import 'package:pwc/model/enums.dart';
import 'package:pwc/security/AesEncryption.dart';
import 'package:pwc/security/CheckSumGenerator.dart';
import 'package:pwc/security/Encryption.dart';
import 'package:pwc/security/HMACChecksumGenerator.dart';
import 'package:pwc/security/RSAEncryption.dart';
import 'package:pwc/security/SHACheckSumGenerator.dart';

class EncryptionFactory{

  static String RSA_SEPARATOR = "}#{";
  /**
   * return Encryption Object on basis of encryptionType
   */
  static Encryption getEncryption(EncryptionType encryptionType) {
    if(EncryptionType.AES ==encryptionType){
      return AesEncryption.instance;
    }
    else if(EncryptionType.AES ==encryptionType){
      return RSAEncryption.instance;
    }
  }

  /**
   *
   * return checksumGenerator
   */
  static CheckSumGenerator getCheckSumGenerator(CheckSumType checkSumType) {
    if(CheckSumType.HMAC==checkSumType){
      return HMACChecksumGenerator();
    }else if(CheckSumType.SHA512 == checkSumType){
      return SHACheckSumGenerator();
    }
  }



}

