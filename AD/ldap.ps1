#LDAP Queries for Group Scope
#Suppose you want to view all Global Groups in your domain? How would you do this? LDAP Queries! LDAP queries for group scope are a little weird... however here is the commands you need:

#All Security Groups with a type of Global
(&(objectCategory=group)(groupType:1.2.840.113556.1.4.803:=2147483650))

#All Security Groups with a type of Domain Local
(&(objectCategory=group)(groupType:1.2.840.113556.1.4.803:=2147483652))

#All Security Groups with a type of Universal
(&(objectCategory=group)(groupType:1.2.840.113556.1.4.803:=2147483656))

#All Distribution Groups with a type of Global:
(&(objectCategory=group)(groupType:1.2.840.113556.1.4.803:=2)(!(groupType:1.2.840.113556.1.4.803:=2147483648)))

#All Distribution Groups with type of Domain Local:
(&(objectCategory=group)(groupType:1.2.840.113556.1.4.803:=4)(!(groupType:1.2.840.113556.1.4.803:=2147483648)))

#All Distribution Groups with type of Universal:
(&(objectCategory=group)(groupType:1.2.840.113556.1.4.803:=8)(!(groupType:1.2.840.113556.1.4.803:=2147483648)))