--
-- Portable PHP password hashing framework.
-- @package phpass
-- @since 2.5.0
-- @version 0.5 / WordPress
-- @link https://www.openwall.com/phpass/
--

package body Inc_Class_Phpass
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Iteration_Count_Log2 : Natural;
                         Portable_Hashes      : Boolean)
                         return Password_Hash
   is
      This : Password_Hash;
   begin
      return This;
   end X_Construct;
        -- then
        --         this.itoa64 = './0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

        --         if (iteration_count_log2 < 4 || iteration_count_log2 > 31)
        --                 iteration_count_log2 = 8;
        --         this.iteration_count_log2 = iteration_count_log2;

        --         this.portable_hashes = portable_hashes;

        --         this.random_state = microtime();
        --         if (function_exists('getmypid'))
        --                 this.random_state .= getmypid();
        -- end;

   ------------------
   -- HashPassword --
   ------------------

   function HashPassword (This     : Password_Hash;
                          Password : String)
                          return String
   is
   begin
      return "XXX-953";
   end HashPassword;

end Inc_Class_Phpass;
