# ActiveAnnotations

ActiveAnnotations is a gem for modeling simple [OpenAnnotation](http://www.openannotation.org/)-compatible annotations to Rails. It is ActiveRecord compatible, but is backed by an RDF graph that serializes (by default) to [JSON-LD](http://json-ld.org/).

* The `source_uri` and the serialized annotation are stored in ActiveRecord; other methods access the underlying graph.
* All attributes are optional.
* Target selectors are currently limited to time-based media fragments, but will be generalized in future iterations.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_annotations'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_annotations

## Usage

```ruby
note = ActiveAnnotations::Annotation.create
note.label = 'This is the annotation label'
note.annotated_by = 'https://github.com/mbklein/'
note.annotated_at = DateTime.now
note.content = 'The five boxing wizards jump quickly.'
note.source = thing # thing is expected to respond to :rdf_uri and :rdf_type
note.start_time = 3.5
note.end_time = 10.75
note.save

puts note.pretty_annotation

{
  "@context": "http://www.w3.org/ns/oa-context-20130208.json",
  "@id": "urn:uuid:8621a944-1912-4df7-91ad-6d4654e3d3ab",
  "@type": "oa:Annotation",
  "annotatedBy": "https://github.com/mbklein/",
  "hasBody": {
    "@id": "urn:uuid:a556399c-6012-4c50-b166-828ca2100647",
    "@type": [
      "cnt:ContentAsText",
      "dctypes:Text"
    ],
    "chars": "The five boxing wizards jump quickly."
  },
  "hasTarget": {
    "@id": "urn:uuid:760bc20d-98a3-49a7-8119-6d0b67574d8d",
    "@type": "oa:SpecificResource",
    "hasSelector": {
      "@id": "urn:uuid:20b34203-5a5f-4cda-be15-123ac6714e4f",
      "@type": "oa:FragmentSelector",
      "conformsTo": "http://www.w3.org/TR/media-frags/",
      "value": "t=3.5,10.75"
    },
    "hasSource": {
      "@id": "http://www.example.org/thing/to/be/annotated",
      "@type": "dctypes:MovingImage"
    }
  },
  "label": "This is the annotation label",
  "oa:annotatedAt": {
    "@value": "2016-04-22T12:14:01-05:00",
    "@type": "xsd:dateTime"
  }
}
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/active_annotations.


## License

The gem is available as open source under the terms of the [Apache License](http://www.apache.org/licenses/LICENSE-2.0).
