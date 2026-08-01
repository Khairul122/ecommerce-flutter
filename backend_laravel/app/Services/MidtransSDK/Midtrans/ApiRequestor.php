<?php

namespace Midtrans;

use Exception;

class ApiRequestor
{
    public static function get($url, $server_key, $data_hash)
    {
        return self::remoteCall($url, $server_key, $data_hash, 'GET');
    }

    public static function post($url, $server_key, $data_hash)
    {
        return self::remoteCall($url, $server_key, $data_hash, 'POST');
    }

    public static function patch($url, $server_key, $data_hash)
    {
        return self::remoteCall($url, $server_key, $data_hash, 'PATCH');
    }

    public static function remoteCall($url, $server_key, $data_hash, $method)
    {
        $ch = curl_init();

        if (!$server_key) {
            throw new Exception('The ServerKey/ClientKey is null.');
        }

        $curl_options = array(
            CURLOPT_URL => $url,
            CURLOPT_HTTPHEADER => array(
                'Content-Type: application/json',
                'Accept: application/json',
                'User-Agent: midtrans-php-v2.6.2',
                'Authorization: Basic ' . base64_encode($server_key . ':')
            ),
            CURLOPT_RETURNTRANSFER => 1
        );

        if (Config::$appendNotifUrl) Config::$curlOptions[CURLOPT_HTTPHEADER][] = 'X-Append-Notification: ' . Config::$appendNotifUrl;
        if (Config::$overrideNotifUrl) Config::$curlOptions[CURLOPT_HTTPHEADER][] = 'X-Override-Notification: ' . Config::$overrideNotifUrl;
        if (Config::$paymentIdempotencyKey) Config::$curlOptions[CURLOPT_HTTPHEADER][] = 'Idempotency-Key: ' . Config::$paymentIdempotencyKey;

        if (count(Config::$curlOptions)) {
            if (isset(Config::$curlOptions[CURLOPT_HTTPHEADER])) {
                $mergedHeaders = array_merge($curl_options[CURLOPT_HTTPHEADER], Config::$curlOptions[CURLOPT_HTTPHEADER]);
                $headerOptions = array(CURLOPT_HTTPHEADER => $mergedHeaders);
            } else {
                $headerOptions = array(CURLOPT_HTTPHEADER => array());
            }
            $curl_options = array_replace_recursive($curl_options, Config::$curlOptions, $headerOptions);
        }

        if ($method != 'GET') {
            if ($data_hash) {
                $body = json_encode($data_hash);
                $curl_options[CURLOPT_POSTFIELDS] = $body;
            } else {
                $curl_options[CURLOPT_POSTFIELDS] = '';
            }

            if ($method == 'POST') {
                $curl_options[CURLOPT_POST] = 1;
            } elseif ($method == 'PATCH') {
                curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'PATCH');
            }
        }

        curl_setopt_array($ch, $curl_options);

        $result = curl_exec($ch);

        if ($result === false) {
            throw new Exception('CURL Error: ' . curl_error($ch), curl_errno($ch));
        } else {
            try {
                $result_array = json_decode($result);
            } catch (Exception $e) {
                throw new Exception("API Request Error unable to json_decode API response: ".$result);
            }
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            if (isset($result_array->status_code) && $result_array->status_code >= 401 && $result_array->status_code != 407) {
                throw new Exception('Midtrans API Error: ' . $result, $result_array->status_code);
            } elseif ($httpCode >= 400) {
                throw new Exception('Midtrans API Error: ' . $result, $httpCode);
            } else {
                return $result_array;
            }
        }
    }
}
