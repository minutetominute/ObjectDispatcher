#ObjectDispatcher

ObjectDispatcher is a lightweight object relational mapper written in Ruby.  Features include creating objects from model definitions, table searching, and model associations.

##Features

ObjectDispatcher dynamically generates object names, parameters, and methods using metaprogramming and values pulled from an sqlite3 database.  This library provides an API to query the database and produce objects through the Searchable module.  Associatable is a module that further extends the SQLObject class by adding belongs_to, has_many, and has_one_through association methods.

##Quickstart
Inherit from SQLObject:
 ```
class Human < SQLObject
end

human = Human.new(name: "Bob")
```
