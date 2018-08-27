class Person
  def initialize(first_name)
    @first_name = first_name  # => "John", "Doe"
  end                         # => :initialize
  attr_accessor :first_name   # => nil
end                           # => nil

### Class
Person.class               # => Class
Person.superclass          # => Object
Person.ancestors           # => [Person, Object, Kernel, BasicObject]
Person.instance_variables  # => []
# Note:
# Quick note on how an object can indicate it's class
# ** "'klass' always points to 'RClass'". How do we conclude that?
# RObject is a Struct(C programming Structure) for an object.
# RObject has a pointer 'klass' which used to indicate the class it was instantiated from.
# RObject's klass pointer point to RClass struct the the class. Ex. person = Person.new. So klass of person points to Person's 'RClass' Struct
#
# 1. When Person class is created, it is born with a special Struct call 'RClass and rb_classext_struct'
#   ** RClass + rb_classext_struct : every class has RClass and rb_classext_struct Struct
#   RClass Struct contains:
#     * RBasic
#       * klass - class pointer : is used to findout the class it was instantiated from. in this case it klass -> <Class:Metaclass#klass>-><Class>, read the section "Where does Ruby store class methods?"
#       * flag
#     * m_table - methods table : Keep all methods defined in the class
#       - it's a Hash object
#         - keys : method name/ ID
#         - value : pointer to methods definition in YARV instruction
#     * iv_index_tbl - instance-level atrribute name
#       - It's a Hash object
#         - Keys : Variables name
#         - Values: index of attributes's values in RObject's instance variable array
#       >It worth notice that when an instance send a message to instance_variable_set(@var, "val"), the copy of new variable is only available in the object scope itself, not to class or other objects that share the class
#     * ptr - pointer to rb_classext_struct
#   rb_classext_struct(saves internal values that they didn’t want to expose in the public Ruby C extension API) contains:
#     * super - super class pointer. If Person<HomoSapiens, super points to RClass of HomoSapiens
#     * const_tbl - contant table. the implementation is the same to iv_table, the class-level variables. but using different Struct
#     * iv_tble - class-level instance variables stores name and value of Class Instance Variable and Class Variable
#   ********Class Instance Variables Vs Class Variables
#         - Class Instance Variables
#           - Created with single @, the variable are passed down to the inheritance Heirachy as a new copy of the object
              # class Mathematic
              #   @type = 'Mathematic'           # => "Mathematic"
              #   class << self                  # => Mathematic
              #     attr_reader :type  # => nil
              #   end                  # => nil
              # end                              # => nil

              # class Statistic < Mathematic  # => Mathematic
              #   @type = 'Statistic'         # => "Statistic"
              # end                           # => "Statistic"

              # Mathematic.type              # => "Mathematic"
              # Statistic.type               # => "Statistic"

#         - Class Variables
  #         - Created with @@, the variable shared accross inheritance Heirachy
                # class Mathematic
                #   @@type = 'Mathematic'    # => "Mathematic"
                #   def self.type
                #     @@type                 # => "Statistic", "Statistic"
                #   end                      # => :type
                # end                        # => :type

                # class Statistic < Mathematic  # => Mathematic
                #   @@type = 'Statistic'        # => "Statistic"
                # end                           # => "Statistic"

              # Mathematic.type                  # => "Statistic"
              # Statistic.type                   # => "Statistic"
# 2. With Ruby code 'class Person', an object is instantiated with name 'Person' whose class is 'Class'
#   This is the idea behind class is also an object
#   From 'RClass' Struct of Person, the pointer 'klass' is know as 'class pointer'
#   An object's klass pointer indicate which class it was instantiated from by pointing to a specific 'RClass' of class 'Class'
# 3. class Person, as an object itself, it should have methods and instance variables defined in 'Class'
# 4. Where does Store Class Method?
#   - Short answer, a mysterious class called Singleton class.
#   - What is a Singleton class?
#     When a new class is created, Ruby allocates 2 objects to object space.
#     * One object is the new class, Ex. Mathematic
#     * The other Object is metaclass. Ex. <Class:Mathematic>
#     * This meta class is created to save the class methods
#     Ex. We have
#     class Mathematic
#     m = Mathematic.new
#     <Class:Mathematic*m_tble> -> Class Methods (Names, Definitions)
#     >show the meta class with 'Mathematician.singleton_class'
#     >show all class Methods p obj.singleton_class.methods
#
#     Some Confusion
#     The truth is Ruby always set this Methaclass to be the class of the new class
#     RObject <m*klass>          points-> RClass <Mathematic>
#       # if m.class we get 'Mathematic'
#     <Mathematic*klass>         points-> RClass of Mata class <Class:Mathematic>
#       # But Why Mathematic.class is 'Class'?
#
#     since, RClass <Class:Mathematic*klass> -> RClass of 'Class'
#     Ruby treat the RClass a bit special than RObject.
#     <Class:Mathematic> is a Replication of Class,
#     Doing this, the class's Methods remain in their own domain, meta <Class:Mathematic>, meaing that it does not touch Class
#     And <Mathematic> RClass'klass still be able to Find out that the class is Class, because of <Class:Mathematic>
class A
  def self.class_method
  end                    # => :class_method
end                      # => :class_method

a = A.new                          # => #<A:0x00007feaf504e088>
a.class                            # => A
A.class                            # => Class
A.singleton_class                  # => #<Class:A>
A.singleton_class.class            # => Class
### Object
person = Person.new('John')        # => #<Person:0x00007feaf504d480 @first_name="John">
person2 = Person.new('Doe')        # => #<Person:0x00007feaf504d0c0 @first_name="Doe">
person.class                       # => Person
# person.superclass    # ~> NoMethodError: undefined method `superclass' for #<Person:0x00007f94cb961e98>
# person.ancestors     # ~> NoMethodError: undefined method `ancestors' for #<Person:0x00007fb7988abef0>

person.first_name = 'John'  # => "John"
person.first_name.class     # => String
person.instance_variables   # => [:@first_name]
# person.first_name.ancestors  # ~> NoMethodError: undefined method `ancestors' for "John":String
# person.first_name.superclass  # ~> NoMethodError: undefined method `superclass' for "John":String

# person                # => #<Person:0x00007ffad281c020>
# person2               # => #<Person:0x00007ffad2083d40>

# Note:
# #<Person:0x00007ffad281c020> and #<Person:0x00007ffad2083d40>
# The Hex String after 'Person:' is the value of pointer to RObject
# As mentioned about RObject is C Struct which was created for an object.
# RObject contains:
#   * klass : is a pointer to the RClass of the class it's instantiated from.
#   * ivptr(of type VALUE) : this is how object maintains its object. ivptr is pointer that points to 'array' of instance variables' values.
#     - Each element of the array is of type VALUE
#     - VALUE is a pointer to RObject, or Generic object Structs such as RString, RArray ..etc
#     - Irony, RObject has an arrays that has pointers that point to other RObject... and more
#     - There are 3 types of value worth noticing while obtainng VALUEs
#       1. Value as Custom Object. Ex. class Person, has an attributes call 'nationality' which is of type Nationality. Clearly Nationality is a class
#       2. Value as Generic Object. Ex. name = "John", name's class is String. the same for type Array, Hash, Regexp etc
#       3. Value as Simple Ruby Value. Ex. True, False,Bignum, Float
#   * iv_index_tbl(of type hash st_table): points to a hash table.
#     - The Hash table maps (Names,Values) pairs,
#     - it maps the attributes_name of RClass to the array of attributes values maintined by ivptr
# ** Value as Custom Object
#   VALUE point to RObject of that attribute
#
# ** Value as Generic Object
#   VALUE point to Generic Struct
#   String, Integer, Symbols are internal/generic Ruby class
#   Ex. Unlike 'person' which is an object of 'custom class Person', the object of a Generic class does not have RObject C Structure.
#   Instead of RObject Struct, instance of String was obtained with RString Struct
#   RArray for Array's object
#   RRegexp for Regexp's object
#   ... etc
#   How are these RString, RRegexp, RArray behave like RObject?
#   Generic Struct contains
#     - Generic value/info : RString maintain string info, RArray maintains array info.
#       If the value is of Type String, then this is where the actual value of string is stored.
#     - RBasic :
#       Basically, RBasic is created so that it's the Generic Structs, RString/RArray should behave like RObject.
#       This is the ideal way of designing Ruby object, both custom and generic
#       Like RObject, RBasic contains:
#         - klass pointer
#         - flag
#
# ** Simple Ruby Value- SRV
#   Integer is classified as SRV
#   In the array of ivptr, VALUEs are also obtained by the RObject for SRV
#   SRV VALUEs is not a pointer, it is a Struct.
#   Unlike Generic or Custom value
#   SRV VALUE contains
#     - Value : if it's an integer, it has integer value
#     - Flag  : since does not point to any class, it use the Flag pointer to indicate the types
#       - Fixnums :  Ex. FIXNUM_FLAG
#       - Boolean
#       - Float
# Let's dig deeper
# *** Do Generic Objects Have Instance Variables?
s = 'Hello Ruby'                                     # => "Hello Ruby"
s.instance_variables                                 # => []
s.instance_variable_set('@iv', 'This is the value')  # => "This is the value"
s.instance_variables                                 # => [:@iv]

a = []                                               # => []
a.instance_variables                                 # => []
a.instance_variable_set('@iv', 'This is the value')  # => "This is the value"
a.instance_variables                                 # => [:@iv]

# i = 1                              # => 1
# i.instance_variables               # => []
# i.instance_variable_set("@iv", 2)  # ~> FrozenError: can't modify frozen Integer
# i.instance_variables

# i = 1.1                            # => 1.1
# i.instance_variables               # => []
# i.instance_variable_set("@iv", 2)  # ~> FrozenError: can't modify frozen Float
# i.instance_variables

# So, beside SRV, every Ruby value is an object and every object contains a class pointer and an array of instance variables.
# Let's dive deeper
# Where Does Ruby Save Instance Variables for Generic Objects?
# s = "the String Value"
# RString Struct has an internal heap struct to keep the value: "Hello Ruby"
# s.instance_variable_set("@iv", "This is the instance variable 's value of object s")  # => "This is the value"
# when instance_variable_set is call, Ruby Responsible for creating an element of a special Hash 'generic_iv_tbl'
# generic_iv_tbl is a type st_table, it a (Object, HashValue) pairs
# generic_iv_tbl: { str => hash }
#   - str: ponter point to RString class 's'
#   - hash: pointer point to { @iv => "This is the instance variable 's value of object s" }
