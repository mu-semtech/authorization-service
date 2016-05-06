# authorization
authorization describes how and provides resources to include authorization in a custom mu-semtech project

## Running the authorization microservice

### Add it to a mu-semtech project

To add authorization to a mu-semtech project you would need to do the following:
<ul>
<li>add the missing, if any, prefixes to repository.lisp</li>
<li>make sure that all resources are added or augmented in your domain.lisp file</li>
<li><optional> add the authorization model triples to your database, if you choose to use custom triples make sure that you understand the model completely</li>
<li><optional>augment the basic authorization triples with specific triples for your application (ie perhaps you need extra tokens like approve or aggregate</li>
<li><optional> the <a href="http://www.github.com/mu-semtech/ember-mu-authoriation">ember-mu-authorization addon</a> will provide your front end with a quick and customizable authorization management console</li>
<li><optional> add a triple for each artifact on which authorization has to be enforced, this triple will be <artifact-id> a auth:artifact</li>
</ul>

### Run the authorization service as a microservice

To run this authorization service as a modified mu-cl-resources please do:
```
docker run --name mu-authorization \
       -p 80:80
       --link database:database
       -d flowofcontrol/authorization-service
```
The basic authorization triples still have to be added to the triple store.

## The authorization query

The following sparql query will allow your microservice to test whether the currently active user has (a) token(s) on the passed artifact(s)(group).
```
display query here
```


## the authorization model
### prefixes
auth: <http://mu.semte.ch/vocabularies/authorization/></br>
foaf: <http://xmlns.com/foaf/0.1/></br>
mu: <http://mu.semte.ch/vocabularies/core/></br>
dct: <http://purl.org/dc/terms/>

### entities
The authorization model constists of the following entities:
<table>
<tr><td>entity</td><td>short description</td><td>type</td><td>properties</br><ul><li>arity name predicate</li></ul></td></tr>
<tr><td>user</td>
<td>A user is a real person who will be using the system.</td>
<td>foaf:Person</td>
<td><ul><li>[1] uuid mu:uuid</li><li>[1] name foaf:name</li><li>[*] grant auth:hasRight</li></ul></td></tr>
<tr><td>userGroup</td>
<td>A user group can contain none, one or multiple users and none, one or multiple other user groups which do not contain it.</td>
<td>foaf:Group</td>
<td><ul><li>[1] uuid mu:uuid</li><li>[1] name foaf:name</li>
<li>[*] user inverse auth:belongsToAccessGroup</li>
<li>[*] subgroup inverse auth:belongsToGroup</li>
<li>[*] parentgroup auth:belongsToGroup</li><li>[*] grant auth:hasRight</li></td></tr>
<tr><td>authenticatable</td>
<td>An authenticatable represents an object or a collection of objects on which a user can (himself or through rights granted by a group to which he belongs) have access rights. An authenticatable can belong to another authenticatable.</td>
<td>auth:authenticatable</td>
<td><ul><li>[1] uuid mu:uuid</li><li>[1] title dct:title</li>
<li>[*] group auth:belongsToArtifactGroup</ul></td></tr>
<tr><td>access token</td>
<td>An access token represents an abstract type of authorization that can be granted to a user. There are 4 "standard" access tokens:<ul><li>create</li><li>delete</li><li>show</li><li>update</li></ul>. A microservice can offer support for different types of access tokens.</td>
<td>auth:accessToken</td>
<td><ul><li>[1] uuid mu:uuid</li><li>[1] title dct:title</li><li>[1] description dct:description</li></ul></td></tr>
<tr><td>grant</td>
<td>A grant represents a link between on one hand one or more access tokens an on the other hand one or more authenticatables.</td>
<td>auth:grant</td>
<td><ul><li>[1] uuid mu:uuid</li><li>[*] accessToken auth:hasToken</li><li>[*] authenticatable auth:operatesOn</li></ul></td></tr>
</table>

## adding authorization to a mu-semtech project
### data
To work authorization will expect certain basic triples to be present in the triple store. You can add/alter them manually or you can include the turtle file that you find in /data/toLoad/basic-access-tokens.ttl.
This turtle file defines the 4 basic access tokens types (show, update, create, delete), a group of basic access tokens, a grant that allows show/update/create rights on that group and an administrator user group that has these rights. The administrator group itself is also an authenticdable but there are no rights defined on this group.

### adding authorization in a docker compose setup
This is an example docker-compose.yml file that includes mu-authorization
```
identifier:
  image: semtech/mu-identifier:1.0.0
  ports:
    - "80:80"
  links:
    - dispatcher:dispatcher
dispatcher:
  image: semtech/mu-dispatcher:1.0.1
  volumes:
    - ./config/dispatcher:/config
  links:
    - resource:resource
database:
  image: tenforce/virtuoso:virtuoso-v7.2.0-latest
  environment:
    SPARQL_UPDATE: "true"
    DEFAULT_GRAPH: http://mu.semte.ch/application
    DBA_PASSWORD: dba
  ports:
    - "8890:8890"
  volumes:
    - ./data/db:/var/lib/virtuoso/db
resource:
  image: semtech/mu-cl-resources:1.8.1
  volumes:
    - ./config/resources:/config
  links:
    - database:database
  ports:
    - 8080:80
```
