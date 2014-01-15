---
layout: post
title: ActiveMusicbrainz - How to use the Musicbrainz database from Ruby
tags:
- ruby
- activerecord
- musicbrainz
---

If you need to use [Ruby](https://www.ruby-lang.org) to access the [Musicbrainz database](http://musicbrainz.org/doc/MusicBrainz_Database) you can use [ActiveMusicbrainz](https://github.com/pilu/active_musicbrainz).
ActiveMusicbrainz is a library based on [ActiveRecord](http://edgeguides.rubyonrails.org/active_record_basics.html) that automatically creates one model for each Musicbrainz table and defines the main associations between them.

If you want to use it in a rails application, add the gem dependency to the Gemfile:

    gem 'active_musicbrainz'

You need to initialize the library after connecting to the database. In rails you can add the following line inside a file in your initializers folder:

    ActiveMusicbrainz.init

The line above will initialize all the models, one for each table, even if they are not defined in the library.

Now you can start playing with the musicbrainz database. You can use the `by_gid` method on all the Models that have a gid column, which defines the [MBID](http://wiki.musicbrainz.org/MusicBrainz_Identifier) of that resource:

    artist = ActiveMusicbrainz::Model::Artist.by_gid '9a709693-b4f8-4da9-8cc1-038c911a61be'
    => #<ActiveMusicbrainz::Model::Artist id: 24146, gid: "9a709693-b4f8-4da9-8cc1-038c911a61be", name: "Bonobo", sort_name: "Bonobo", begin_date_year: 1976, begin_date_month: 3, begin_date_day: 30, end_date_year: nil, end_date_month: nil, end_date_day: nil, type: 1, area: 221, gender: 1, comment: "UK electro artist Simon Green", edits_pending: 0, last_updated: "2013-05-13 11:00:09", ended: false, begin_area: nil, end_area: nil>

    artist.name
    => "Bonobo"

    artist.release_groups.first.type
    => #<ActiveMusicbrainz::Model::ReleaseGroupPrimaryType id: 1, name: "Album">

    artist.release_groups.each{|r| puts r.name }
    Black Sands
    Dial 'M' for Monkey
    Scuba EP
    Flutter
    Pick Up
    Terrapin
    Eyesdown
    ...

    artist.release_groups.first.releases.first.mediums
    => [#<ActiveMusicbrainz::Model::Medium id: 654199, release: 654199, position: 1, format: 1, name: nil, edits_pending: 0, last_updated: "2012-01-15 13:46:18", track_count: 12>]

    artist.release_groups.first.releases.first.mediums.first.tracks.each{|t| puts t.name}
    Prelude
    Kiara
    Kong
    Eyesdown
    ...

    artist.release_groups.first.releases.first.mediums.first.format
    => #<ActiveMusicbrainz::Model::MediumFormat id: 1, name: "CD", parent: nil, child_order: 0, year: 1982, has_discids: true>

Check out the project on [Github](https://github.com/pilu/active_musicbrainz) for more info.
