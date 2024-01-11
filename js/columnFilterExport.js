/*
Copyright Vassilis Petroulias [DRDigit]

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

modified by Pierre-Emmanuel Périllon

*/
var Base64 = {
    alphabet: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='.split('') ,
    lookup: null,
	regex:/^[\x00-\x7f]*$/,
    encode: function (s) {
        var buffer = Base64.toUtf8(s),
            position = -1,
            len = buffer.length,
            nan0, nan1, nan2, enc = [, , , ];
            var result = '';
            while (++position < len) {
                nan0 = buffer[position];
                nan1 = buffer[++position];
                enc[0] = nan0 >> 2;
                enc[1] = ((nan0 & 3) << 4) | (nan1 >> 4);
                if (isNaN(nan1))
                    enc[2] = enc[3] = 64;
                else {
                    nan2 = buffer[++position];
                    enc[2] = ((nan1 & 15) << 2) | (nan2 >> 6);
                    enc[3] = (isNaN(nan2)) ? 64 : nan2 & 63;
                }
                result+=Base64.alphabet[enc[0]] +Base64.alphabet[enc[1]]+Base64.alphabet[enc[2]]+Base64.alphabet[enc[3]];
            }
            return result;
    },
    decode: function (s) {
        if (s.length % 4)
            throw new Error("InvalidCharacterError: 'Base64.decode' failed: The string to be decoded is not correctly encoded.");
        var buffer = Base64.fromUtf8(s),
            position = 0,
            len = buffer.length;
            var result = '';
            while (position < len) {
                if (buffer[position] < 128) 
                    result += String.fromCharCode(buffer[position++]);
                else if (buffer[position] > 191 && buffer[position] < 224) 
                    result += String.fromCharCode(((buffer[position++] & 31) << 6) | (buffer[position++] & 63));
                else 
                    result += String.fromCharCode(((buffer[position++] & 15) << 12) | ((buffer[position++] & 63) << 6) | (buffer[position++] & 63));
            }
            return result;
    },
    toUtf8: function (s) {
        var position = -1,
            len = s.length,
            chr, buffer = [];
        if (Base64.regex.test(s)) while (++position < len)
            buffer.push(s.charCodeAt(position));
        else while (++position < len) {
            chr = s.charCodeAt(position);
            if (chr < 128) 
                buffer.push(chr);
            else if (chr < 2048) 
                buffer.push((chr >> 6) | 192, (chr & 63) | 128);
            else 
                buffer.push((chr >> 12) | 224, ((chr >> 6) & 63) | 128, (chr & 63) | 128);
        }
        return buffer;
    },
    fromUtf8: function (s) {
        var position = -1,
            len, buffer = [],
            enc = [, , , ];
		var t = s.split("");
        if (!Base64.lookup) {
            len = Base64.alphabet.length;
            Base64.lookup = {};
            while (++position < len) Base64.lookup[Base64.alphabet[(position)]] = position;
            position = -1;
        }
        len = t.length;
        while (++position < len) {
            enc[0] = Base64.lookup[s[position]];
            enc[1] = Base64.lookup[s[++position]];
            buffer.push((enc[0] << 2) | (enc[1] >> 4));
            enc[2] = Base64.lookup[s[++position]];
            if (enc[2] == 64) 
                break;
            buffer.push(((enc[1] & 15) << 4) | (enc[2] >> 2));
            enc[3] = Base64.lookup[s[++position]];
            if (enc[3] == 64)  break;
            buffer.push(((enc[2] & 3) << 6) | enc[3]);
        }
        return buffer;
    }
};

















