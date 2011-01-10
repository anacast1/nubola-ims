<?php

  // disable warnings about iv not properly set, since
  // in ECB mode we don't need iv
  error_reporting(0);

  $input = $argv[1];

  $key = "a84Gh9irTu6341HjkllmT72uLoPd8na3";
  $cipher_alg = MCRYPT_RIJNDAEL_256;
  $mode = MCRYPT_MODE_ECB;

  //print "Original string: $input (".base64_encode($input).")";

  $encrypted_string = mcrypt_encrypt($cipher_alg, $key, $input, $mode);
  $b64Encoded = base64_encode($encrypted_string);

  print $b64Encoded;

  /*$decrypted_string = mcrypt_decrypt($cipher_alg, $key, $encrypted_string, MCRYPT_MODE_CBC);

  print "Decrypted string: $decrypted_string";

  print "Each byte=";
  for ($i=0,$j = strlen($encrypted_string);$i < $j; $i++) {
    print ord($encrypted_string[$i])." ";
  }*/
?>