(in-package :mu-cl-resources)

;; definition of a user
;;
;; a user has a name
;;        has relations to user groups
;;        has access-tokens which give it rights to resources
(define-resource user ()
  :class (s-prefix "foaf:Person")
  :resource-base (s-url "http://mu.semte.ch/services/authorization-service/users/")
  :features '(no-pagination-defaults)           
  :properties `((:name :string ,(s-prefix "foaf:name")))
  :has-many `((grant :via ,(s-prefix "auth:hasRight")
			       :as "grants")
	      )
  :on-path "users")

;; definition of a user-group
;;
;; a user-group can contain other user-groups
;;              can contain users
;;              has authorization types on objects
(define-resource user-group ()
  :class (s-prefix "foaf:Group")
  :resource-base (s-url "http://mu.semte.ch/services/authorization-service/groups/")
  :features '(no-pagination-defaults)           
  :properties `((:name :string ,(s-prefix "foaf:name")))
  :has-many `((user :via ,(s-prefix "auth:belongsToActorGroup")
		    :inverse t
                    :as "users")
	      (user-group :via, (s-prefix "auth:belongsToGroup")
			  :inverse t
			  :as "sub-groups")
	      (user-group :via, (s-prefix "auth:belongsToGroup")
			  :as "parent-groups")
	      (grant :via ,(s-prefix "auth:hasRight")
			       :as "grants"))
  :on-path "user-groups")

;; authenticatable
;; an authenticatable is something on which rights can be given to either users
;; or user groups, it has a name and a uuid

(define-resource authenticatable ()
  :class (s-prefix "auth:Authenticatable")
  :resource-base (s-url "http://mu.semte.ch/services/authorization-service/authenticatables/")
  :features '(no-pagination-defaults)           
  :properties `((:title :string, (s-prefix "dct:title")))
  :on-path "authenticatables")

;; access-token
;; describes a certain type of access token
;; we assume there to be 4 basic access token types that should
;; be present to make mu-cl-resources handle the access token stuff
;; correctly (show, update, create, delete)
(define-resource access-token ()
  :class (s-prefix "auth:AccessToken")
  :resource-base (s-url "http://mu.semte.ch/services/authorization-service/access-tokens/")
  :features '(no-pagination-defaults)           
  :properties `((:title :string ,(s-prefix "dct:title"))
		(:description :string ,(s-prefix "dct:description"))
		)
  :on-path "access-tokens")


;; grant
;; a grant is used to determine whether or not a user can
;; access a certain resource.
;; It is an instance of an access token definition and thus maps
;; to exactly 1 authenticatable
(define-resource grant ()
  :class (s-prefix "auth:Grant")
  :resource-base (s-url "http://mu.semte.ch/services/authorization-service/grants/")
  :features '(no-pagination-defaults)           
  :has-many `((access-token :via, (s-prefix "auth:hasToken")
			    :as "access-tokens")
	      (authenticatable :via, (s-prefix "auth:operatesOn")
				:as "authenticatables"))
  :on-path "grants")
