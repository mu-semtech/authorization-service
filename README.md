# Authorization service
authorization describes how and provides resources to include authorization in a custom [mu-semtech project](https://mu.semte.ch)

## Running the authorization microservice

### Add it to a mu-semtech project

To add authorization to a mu-semtech project you would need to do the following:

- add the missing, if any, prefixes to `config/resources/repository.lisp`
- make sure that all resources are added or augmented in your domain.lisp file
- [optional] add the authorization model triples from `data/toLoad/basic-access-tokens.ttl` to your database, if you choose to use custom triples make sure that you understand the model completely
- [optional] augment the basic authorization triples with specific triples for your application (ie perhaps you need extra tokens like `approve` or `aggregate`
- [optional] the [ember-mu-authorization addon](http://www.github.com/mu-semtech/ember-mu-authoriation) will provide your front end with a quick and customizable authorization management console
- [optional] add a triple for each artifact on which authorization has to be enforced, this triple will be `<artifact-id> a auth:Authenticatable`

### Data
To work authorization will expect certain basic triples to be present in the triple store. You can add/alter them manually or you can include the turtle file that you find in `data/toLoad/basic-access-tokens.ttl`.
This turtle file defines the 4 basic access tokens types (`show`, `update`, `create`, `delete`), a group of basic access tokens, a grant that allows show/update/create/delete rights on that group and an administrator user group that has these rights. The administrator group itself is also an authenticatable but there are no rights defined on this group.

### adding authorization in a docker compose setup
This is an example `docker-compose.yml` file that includes the authorization service
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
  image: tenforce/virtuoso:1.0.0-virtuoso7.2.2
  environment:
    SPARQL_UPDATE: "true"
    DEFAULT_GRAPH: http://mu.semte.ch/application
    DBA_PASSWORD: dba
  ports:
    - "8890:8890"
  volumes:
    - ./data/db:/data
authorization:
  image: semtech/authorization
  links:
    - database:database
```

### Run the authorization service as a microservice

To run this authorization service as a single docker container please do:
```
docker run --name mu-authorization \
       -p 80:80
       --link database:database
       -d semtech/authorization
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
The authorization model consists of the following entities:
<table>
<t><td><b>entity</b></td><td><b>short description</b></td><td><b>type</b></td><td><b>properties</b></br><ul><li>[arity] name <i>predicate</i></li></ul></td></tr>
<tr><td>user</td>
<td>A user is a real person who will be using the system.</td>
<td>foaf:Person</td>
<td><ul><li>[1] uuid <i>mu:uuid</i></li><li>[1] name <i>foaf:name</i></li><li>[*] grant <i>auth:hasRight</i></li></ul></td></tr>
<tr><td>userGroup</td>
<td>A user group can contain none, one or multiple users and none, one or multiple other user groups which do not contain it.</td>
<td>foaf:Group</td>
<td><ul><li>[1] uuid <i>mu:uuid</i></li><li>[1] name <i>foaf:name</i></li>
<li>[*] user inverse <i>auth:belongsToAccessGroup</i></li>
<li>[*] subgroup inverse <i>auth:belongsToGroup</i></li>
<li>[*] parentgroup <i>auth:belongsToGroup</i></li><li>[*] grant <i>auth:hasRight</i></li></td></tr>
<tr><td>authenticatable</td>
<td>An authenticatable represents an object or a collection of objects on which a user can (himself or through rights granted by a group to which he belongs) have access rights. An authenticatable can belong to another authenticatable.</td>
<td>auth:Authenticatable</td>
<td><ul><li>[1] uuid <i>mu:uuid</i></li><li>[1] title <i>dct:title</i></li>
<li>[*] group <i>auth:belongsToArtifactGroup</i></ul></td></tr>
<tr><td>access token</td>
<td>An access token represents an abstract type of authorization that can be granted to a user. There are 4 "standard" access tokens:<ul><li>create</li><li>delete</li><li>show</li><li>update</li></ul>. A microservice can offer support for different types of access tokens.</td>
<td>auth:AccessToken</td>
<td><ul><li>[1] uuid <i>mu:uuid</i></li><li>[1] title <i>dct:title</i></li><li>[1] description <i>dct:description</i></li></ul></td></tr>
<tr><td>grant</td>
<td>A grant represents a link between on one hand one or more access tokens an on the other hand one or more authenticatables.</td>
<td>auth:Grant</td>
<td><ul><li>[1] uuid <i>mu:uuid</i></li><li>[*] accessToken <i>auth:hasToken</i></li><li>[*] authenticatable <i>auth:operatesOn</i></li></ul></td></tr>
</table>
