---
author: Jonathan François <jfrancois@synbioz.com>
title: Générer la documentation d'une API REST (grape) à partir du code
categories:
  - rails
tags:
  - api
  - grape
  - documentation
  - fr
description: Générer une documentation testable d'une api mis en place à partir de Grape.
publish_on: 2015/03/31
---

Pour faire suite aux articles de [Théo](http://www.synbioz.com/blog/authors/tdelaune) sur la mise en place d'une API RESTFULL avec l'utilisation de la gem [Grape](https://github.com/intridea/grape), nous allons aujourd'hui nous intéresser à la génération de la documentation de l'API.

Pour rappel, voici les liens ainsi que les dépôts Github de ces articles :

- [Créer une API en Ruby on Rails avec la gem Grape](http://www.synbioz.com/blog/api_ruby_rails_gem_grape) - [dépôt Github](https://github.com/synbioz/api_rails_grape_1)
- [Créer une API en Ruby on Rails avec la gem Grape - 2 ème partie](http://www.synbioz.com/blog/api_ruby_rails_gem_grape_2)

La rédaction de la documentation d'une API est une chose assez redouté par de nombreux développeurs. Il est fastidieux de lister à la main tous les endpoints disponibles ainsi que tous les paramètres possibles associés avec leur explication. C'est la raison pour laquelle certaines personnes prennent des raccourcis, c'est ce qui est dommage car une documentation bien conçu est la clé de la réussite de votre API (aussi bien publique que privée).

Même lorsqu'on nous prenons le temps de rédiger une documentation digne de ce nom, il faut ensuite la maintenir car une API a tendance à évoluer très vite et il faut que sa documentation reste à jour. 

Afin de palier à ce problème, j'ai donc rechercher un moyen de la générer automatiquement à partir du code. En effet cette solution permettrait de développer notre API tout en générant automatiquement sa documentation et donc sa mis à jour.

En réalisant mes recherches, je suis tombé sur des services sympa mais payant comme [apiary.io](https://apiary.io/) et des services open source comme [Docco](http://jashkenas.github.io/docco/), [Dexy](http://www.dexy.it/) ou [Swagger](http://swagger.io/). Mon choix s'est rapidement arrêté sur Swagger.

En effet, Swagger permet de décrire, produire, consommer et visualiser les services d'une API RESTFULL ([Démo](http://petstore.swagger.io/)). De nombreuses références comme Apigee, Microsoft ou Paypal l'utilisent et il est 100% open source.

## Swagger et Grape

![Demo_swagger](http://www.synbioz.com/images/articles/Capture d’écran 2015-03-31 à 10.30.07_thumb_450.png)

Swagger est développé en HTML et javascript et permet de créer une documentation interactive et très complète. Comme vous pouvez l' apercevoir sur le screenshot ci-dessus, il permet de catégoriser nos endpoints par ressource (pet, store ou user), puis ensuite utilise des codes couleurs pour spécifier le verbe HTTP utilisé sur l'endpoint. Au clic de l'un de ces endpoints vous avez le détails des paramètres attendus mais également le format de retour de l'api. Vous pouvez également consommer l'api depuis l'interface de documentation ce qui apporte une facilité de compréhension aux lecteurs.

Pour intégrer cette solution à notre projet Rails nous allons utilisés les gems suivantes :

- [gem 'grape-entity'](https://github.com/intridea/grape-entity) -> permet de spécifier les attributs de nos models exposer par l'api
- [gem 'grape-swagger'](https://github.com/tim-vandecasteele/grape-swagger) -> permet de générer la documentation de notre api à partir de notre code 
- [gem 'grape-swagger-rails'](https://github.com/BrandyMint/grape-swagger-rails) -> permet d'embarquer dans notre projet Rails l'UI de Swagger 

Une fois notre `Gemfile` complété, passons à la configuration de ces gems.

### Grape-swagger-rails

Créons un initializer qui contiendra la configuration de la gem grape-swagger-rails. Dans celui-ci nous allons renseigner le nom de notre documentation, l'url de notre application, ainsi que l'url souhaitée pour notre documentation.

~~~ ruby
GrapeSwaggerRails.options.url      = '/api/swagger_doc'
GrapeSwaggerRails.options.app_name = 'CarWorldTrader'
GrapeSwaggerRails.options.app_url  = 'http://localhost:3000'
~~~

Si vous utilisez différents environnements, je vous conseille de renseigner l'url de chacun de votre fichier `secrets.yml`, afin de pouvoir renseigner l'option `app_url` de manière dynamique. Exemple :

~~~ ruby
GrapeSwaggerRails.options.app_url  = Rails.application.secrets.app_domain_name
~~~

Il faut ensuite ajouter les routes répondant à votre documentation :

~~~ ruby
# config/routes.rb
mount GrapeSwaggerRails::Engine => '/apidoc'
~~~

A ce stade, l'interface de documentation de votre API est disponible à cette url `http://localhost:3000/apidoc` mais vide.

Nous allons maintenant voir comment générer automatiquement notre documentation en modifiant légèrement notre code existant de l'API.

### Grape-swagger

Commençons par mettre en place la configuration de  la gem `Grape_swagger` pour générer notre documentation. Cela se réalise via l’utilisation de fonction `add_swagger_documentation`.

~~~ ruby
# app/api/car_world_trader/base.rb
module CarWorldTrader
  class Base < Grape::API
    format :json
    prefix :api

    mount CarWorldTrader::V1::Cars
    add_swagger_documentation(
      base_path: "",
      api_version: "1.0",
      format: :json,
      hide_documentation_path: true,
      info: {
        title: "CarWorldTrader API",
        description: 'API to expose Cars informations form AutoTrader',
        contact: "jfrancois@synbioz.com",
        license: "All Rights Reserved"
        }
    )
  end
end

~~~

- `base_path` : Chemin de base de l'API qui est exposée. Dans notre fichier `routes.rb` nous avions mentionnés `mount CarWorldTrader::Base => '/'`.
- `api_version` : Version courante de l'API
- `format` : Format de réponse de la documentation de l'API
- `hide_documentation_path` : Permet de cacher les routes permettant à swagger d'afficher la documentation. 
- `info` : Informations relatives à l'API qui sera affiché sur votre documentation

D'autres options sont disponibles, je vous laisse consulter la documentation pour plus d’informations : [Configuration](https://github.com/tim-vandecasteele/grape-swagger#configure).

A ce stade nous pouvons déjà voir la documentation générée. Nous allons utiliser la version 1.0 de l'api avec deux modifications :

- suppression de l'authentification http basique
- suppression du numéro de version dans l'url des endpoints

Nous n'avons pas besoin d'authentification `http_basic` pour nos tests, mais cela reste fonctionnel en l'utilisant. Il faudra juste renseigner les identifiants. Concernant ce point vous pouvez toute à fait mettre une authentification sur l'accès à la page de documentation de l'api. Pour cela, il suffit de le spécifier dans la configuration de la gem `grape-swagger-rails`, retrouvez les indications [ici](https://github.com/BrandyMint/grape-swagger-rails#basic-authentication).

L'interface de documentation nous permet déjà d'obtenir la liste de toutes nos routes disponibles sur notre API avec la possibilité de la tester.

![page_demo_1](http://www.synbioz.com/images/articles/Capture%20d%E2%80%99%C3%A9cran%202015-03-31%20%C3%A0%2012.18.06.png)

L'interface répondant à la route `/api/cars` en `POST` :

![page_demo_2](http://www.synbioz.com/images/articles/Capture d’écran 2015-03-31 à 14.13.44.png)

Correspondant au code suivant :

~~~ ruby
desc "Create a car"
params do
  requires :car, type: Hash do
    requires :manufacturer, type: String, regexp: /^[A-Z][a-z]+$/
    requires :design, type: String, values: ["tourer", "racing"]
    requires :style, type: String
    optional :doors, type: Integer, default: 3
  end
end
post do
  Car.create!(params[:car])
end
~~~

La description du code est donc utilisé par swagger pour documenter l'api.
![page_demo_3](http://www.synbioz.com/images/articles/Capture%20d%E2%80%99%C3%A9cran%202015-03-31%20%C3%A0%2014.15.46.png)

Par défault la gem `grape-swagger` va se servir des définitions des paramétres de votre route pour générer la documentation. Il prend en compte les paramètres requis ou non, le type, la valeur par défaut, les valeurs possibles etc... En résumé tout ce que permet de définir la gem `Grape`
sur les paramètres.

On peut donc générer la description ainsi que les informations sur les paramètres de notre endpoint. Afin de pouvoir documenter la réponse de l'appel API nous allons utilisés la gem `grape-entity`.

Cette gem permet de choisir et de définir les attributs que votre endpoint API va exposer. Par ce biais, la gem `grape-swagger` sera capable de l'inclure automatiquement dans notre documentation.

~~~ ruby
module CarWorldTrader
  module V1
    module Entities
      class Car < Grape::Entity
        expose :id, documentation: { type: 'integer', desc: 'Car ID' }
        expose :manufacturer, documentation: { type: 'string', desc: 'Car manufacturer' }
        expose :style, documentation: { type: 'string', desc: 'Car style' }
        expose :doors, documentation: { type: 'integer', desc: 'Car number of doors' } }
      end
    end

    class Cars < Grape::API
      # version 'v1', using: :path

      resource :cars do
        ...
        desc "Create a car", entity: CarWorldTrader::V1::Entities::Car
        params do
          requires :car, type: Hash do
            requires :manufacturer, type: String, regexp: /^[A-Z][a-z]+$/
            requires :design, type: String, values: ["tourer", "racing"]
            requires :style, type: String
            optional :doors, type: Integer, default: 3
          end
        end
        post do
          present Car.create!(params[:car]), with: CarWorldTrader::V1::Entities::Car
        end
        ...
      end
    end
  end
end


~~~

Le module `Entities` permet la création des différentes `class` que nous allons avoir besoin (ici nous n'avons qu'une seule ressource `Car`). Nous spécifions ensuite les différents attributs que nous voulons exposer sur cette ressource via l'API. Retrouvez l'ensemble des paramètres possible pour la documentation sur le [dépôt de la gem](https://github.com/intridea/grape-entity).

Ensuite nous allons, intégrer cette documentation dans la description de notre route :

~~~ ruby
desc "Create a car", entity: CarWorldTrader::V1::Entities::Car
~~~

Ce qui va permettre de générer la mise à jour de l'interface de documentation en présentant le format et les attributs que va nous rendre l'appel API :

![page_demo_4](http://www.synbioz.com/images/articles/Capture%20d%E2%80%99%C3%A9cran%202015-03-31%20%C3%A0%2014.42.51.png)

Il faut maintenant dire à notre api d'utiliser cette classe `Entities` pour spécifier les attributs à exposer :

~~~ ruby
present Car.create!(params[:car]), with: CarWorldTrader::V1::Entities::Car
~~~

Dans notre cas, nous ne présentons pas les attributs `created_at` et `update_at`(juste pour l'exemple).

## Conclusion

Avoir une interface de documentation qui s'adapte à notre code et se mettant à jour automatiquement est vraiment un gain de temps, d'autant que celle-ci permet de consommer l'api. Notre exemple est volontairement basique et nous n'avons pas parcouru l'ensemble des options possibles à la documentation mais le but de l'article étant de vous mettre la puce à l'oreille sur ce genre d'outils.

En espérant que cela vous fasse gagner du temps et vous permettent d'éditer des documentations API sans trop d'effort.

L’équipe Synbioz.

Libres d’être ensemble.
