`define uvm_component_utils(T) \
   typedef uvm_component_registry #(T,`"S`") type_id; \
   static function type_id get_type(); \
     return type_id::get(); \
   endfunction \
   virtual function uvm_object_wrapper get_object_type(); \
     return type_id::get(); \
   endfunction
   static function string type_name(); \
       return TNAME_STRING; \
     endfunction : type_name \
     virtual function string get_type_name(); \
       return TNAME_STRING; \
     endfunction : get_type_name

