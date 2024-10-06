# cdata
Simple Tavern AI Card Data Editor
## Description
cdata.pl is a script that lets you quickly read and edit Tavern card data from the command line. It can read, insert, update, and delete fields from Tavern cards, then save the changes to a new file (or overwrite the original).

It does not work with v1 cards.

## Requirements
* [Perl](https://www.perl.org/get.html)
* [Libpng](https://metacpan.org/dist/Image-PNG-Libpng/view/lib/Image/PNG/Libpng.pod)

## Usage
`perl cdata.pl sourcefile operation field (data) (destfile)`

### Operations
#### read
Reads the value of a field, or the entire card if no field is specified.

Example: 
```
-> perl cdata.pl card.png read name
<- "McGuffin the Brave"
```

#### insert
Inserts a new field with a specified value. Error if the field already exists.

Example:
```
-> perl cdata.pl card.png insert race "Human" card.png
<- Field 'race' inserted with value 'Human'
```

#### update
Updates an existing field with a new value. Error if the field does not exist.

Example:
```
-> perl cdata.pl card.png update personality "Brave, but not too bright" card.png
<- Field 'personality' updated with value 'Brave, but not too bright' card.png
```

#### delete
Deletes a field. Error if the field does not exist.

Example: 
```
-> perl cdata.pl card.png delete age card.png
<- Field 'age' deleted
```
