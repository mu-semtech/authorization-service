# mu-authorization
mu-authorization describes how and provides resources to include authorization in a custom mu-semtech project

# the authorization model
## prefixes
auth: <http://mu.semte.ch/vocabularies/authorization/></br>
foaf: <http://xmlns.com/foaf/0.1/></br>
mu: <http://mu.semte.ch/vocabularies/core/></br>

## entities
The authorization model constists of the following entities:
<table>
<tr><td>entity</td><td>short description</td><td>properties</br>arity name predicate</td></tr>
<tr><td>user</td>
<td>user description</td>
<td><ul><li>[1] uuid mu:uuid</li><li>[1] name mu:name</li><li>[*] grant auth:hasRight</li></ul></td></tr>
<tr><td>group</td>
<td>group description</td>
<td><ul><li>[1] uuid mu:uuid</li><li>[1] name mu:name</li>
<li>[*] user inverse auth:belongsToAccessGroup</li>
<li>[*] subgroup inverse auth:belongsToGroup</li>
<li>[*] parentgroup auth:belongsToGroup</li><li>[*] grant auth:hasRight</li></td></tr>
<tr><td>authenticadable</td>
<td>An authenticadable represents an object or a collection of objects on which a user can (himself or through rights granted by a group to which he belongs) have access rights. An authenticadable can belong to another authenticadable.</td>
<td><ul><li>[1] uuid mu:uuid</li><li>[1] name mu:name</li>
<li>[*] group auth:belongsToArtifactGroup</ul></td></tr>
<tr><td>access token</td>
<td>An access token represents an abstract type of authorization that can be granted to a user. There are 4 "standard" access tokens:<ul><li>create</li><li>delete</li><li>show</li><li>update</li></ul>. A microservice can offer support for different types of access tokens.</td>
<td><ul><li>[1] uuid mu:uuid</li><li>[1] name mu:name</li><li>[1] description mu:description</li></ul></td></tr>
<tr><td>grant</td>
<td>A grant represents a link between on one hand one or more access tokens an on the other hand one or more authenticadables.</td>
<td><ul><li>[1] uuid mu:uuid</li><li>[*] accessToken auth:hasToken</li><li>[*] authenticadable auth:operatesOn</li></ul></td></tr>
</table>

# adding mu-authorization to a mu-semtech project
## data
To work mu-authorization will expect certain basic triples to be present in the triple store. You can add/alter them manually or you can include the turtle file that you find in /data/toLoad/basic-access-tokens.ttl.
This turtle file defines the 4 basic access tokens types (show, update, create, delete), a group of basic access tokens, a grant that allows show/update/create rights on that group and an administrator user group that has these rights. The administrator group itself is also an authenticdable but there are no rights defined on this group.
