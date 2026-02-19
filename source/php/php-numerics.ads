--
--
--

with Arrays;

package Php.Numerics
is
   use Arrays;

   function Intval (Value : String;
                    Base  : Integer := 10)
                    return Integer;

   function Absint (Num : Integer)
                    return Integer;

   function Max (Arry : Array_Type)
                 return Integer
                 is (1);

   function Hexdec (Hex : String)
                    return Integer
                    is (99);

   function MT_Rand (Min : Natural;
                     Max : Natural)
                     return Natural;

   function Round (Num       : Float;
                   Precision : Integer := 0)
                   return Float
                   is (99.99);

   function Rand (Min : Integer;
                  Max : Integer)
                  return Natural
                  is (99);

   function Rand
            return Natural
            is (99);

   function Hash_HMAC (Algo : String;
                       Data : String;
                       Key  : String)
                       return String
   is ("XXX-972");

   function Uniqid (Prefix       : String;
                    More_Entropy : Boolean := False)
                    return String
   is ("XXX-973");

   function Number_Format (Num                 : Float;
                           Decimals            : Integer := 0;
                           Decimal_Separator   : String := ".";
                           Thousands_Separator : String := ",")
                           return String
                           is ("999,999.99");

   function SHA1 (Item : String)
                  return String
                  is ("XXX-884");

   function Hash (Alg  : String;
                  Item : String)
                  return String
                  is ("XXX-883");

end Php.Numerics;
