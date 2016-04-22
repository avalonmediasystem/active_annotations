require 'open-uri'
require 'securerandom'
require 'yaml'
require 'json/ld'
require 'rdf/vocab/dc'
require 'rdf/vocab/oa'
require 'rdf/vocab/cnt'
require 'rdf/vocab/dcmitype'

module ActiveAnnotations  
  class RDFAnnotation
    attr_accessor :context
    attr_reader :graph
    CONTEXT_URI = 'http://www.w3.org/ns/oa-context-20130208.json'
    
    def self.from_jsonld(json)
      content = JSON.parse(json)
      if content['@context'] =~ /\.json$/
        content['@context'] = JSON.parse(open(content['@context']).read)['@context']
      end
      result = self.new(JSON::LD::API.toRDF(content))
      result.context = content['@context']
      result
    end
    
    def to_jsonld(opts={})
      input = JSON.parse(graph.dump :jsonld, standard_prefixes: true, prefixes: { oa: RDF::Vocab::OA.to_iri.value })
      frame = YAML.load(File.read(File.expand_path('../frame.yml',__FILE__)))
      output = JSON::LD::API.frame(input, frame)
      output.merge!(output.delete('@graph')[0])
      if opts[:pretty_json]
        JSON.pretty_generate output
      else
        output.to_json
      end
    end

    def initialize(content=nil)
      @graph = RDF::Graph.new
      if content.nil?
        self.add_default_content!
      else
        @graph << content
      end
    end
    
    def add_default_content!
      aid = new_id
      @graph.insert_statements([
        RDF::Statement.new(aid, RDF.type, RDF::Vocab::OA.Annotation),
        RDF::Statement.new(aid, RDF::Vocab::OA.annotatedAt, DateTime.now)
      ])
    end

    def ensure_body!
      if body_id.nil?
        bid = new_id
        @graph.insert_statements([
          RDF::Statement.new(annotation_id, RDF::Vocab::OA.hasBody, bid),
          RDF::Statement.new(bid, RDF.type, RDF::Vocab::DCMIType.Text),
          RDF::Statement.new(bid, RDF.type, RDF::Vocab::CNT.ContentAsText)
        ])
      end
    end
    
    def ensure_target!
      if target_id.nil?
        tid = new_id
        @graph.insert_statements([
          RDF::Statement.new(annotation_id, RDF::Vocab::OA.hasTarget, tid),
          RDF::Statement.new(tid, RDF.type, RDF::Vocab::OA.SpecificResource)
        ])
      end
    end

    def ensure_selector!
      if selector_id.nil?
        ensure_target!
        sid = new_id
        @graph.insert_statements([
          RDF::Statement.new(target_id, RDF::Vocab::OA.hasSelector, sid),
          RDF::Statement.new(sid, RDF.type, RDF::Vocab::OA.FragmentSelector),
          RDF::Statement.new(sid, RDF::Vocab::DC.conformsTo, RDF::URI('http://www.w3.org/TR/media-frags/'))
        ])
      end
    end
    
    def new_id
      RDF::URI.new("urn:uuid:#{SecureRandom.uuid}")
    end

    def find_id(type)
      statement = @graph.first(predicate: RDF.type, object: type)
      statement.nil? ? nil : statement.subject
    end
    
    def annotation_id
      find_id(RDF::Vocab::OA.Annotation)
    end
    
    def body_id
      statement = @graph.first(subject: annotation_id, predicate: RDF::Vocab::OA.hasBody)
      statement.nil? ? nil : statement.object
    end
    
    def target_id
      find_id(RDF::Vocab::OA.SpecificResource)
    end
    
    def selector_id
      find_id(RDF::Vocab::OA.FragmentSelector)
    end
    
    def context
      @context ||= JSON.parse(open(CONTEXT_URI).read)['@context']
    end
    
    def fragment_value
      graph.first(subject: selector_id, predicate: RDF.value)
    end
    
    def fragment_value=(value)
      ensure_selector!
      @graph.delete({ subject: selector_id, predicate: RDF.value })
      @graph << RDF::Statement.new(selector_id, RDF.value, value) unless value.nil?
    end
    
    def start_time
      fragment_value.nil? ? nil : fragment_value.object.value.scan(/^t=(.*)$/).flatten.first.split(/,/)[0]
    end
    
    def start_time=(value)
      self.fragment_value = "t=#{[value, end_time].join(',')}"
    end
    
    def end_time
      fragment_value.nil? ? nil : fragment_value.object.value.scan(/^t=(.*)$/).flatten.first.split(/,/)[1]
    end
    
    def end_time=(value)
      self.fragment_value = "t=#{[start_time, value].join(',')}"
    end
    
    def content
      if body_id.nil?
        nil
      else
        statement = graph.first(subject: body_id, predicate: RDF::Vocab::CNT.chars)
        statement.nil? ? nil : statement.object.value
      end
    end
    
    def content=(value)
      ensure_body!
      @graph.delete({ subject: body_id, predicate: RDF::Vocab::CNT.chars })
      @graph << RDF::Statement.new(body_id, RDF::Vocab::CNT.chars, value) unless value.nil?
    end
    
    def annotated_by
      statement = @graph.first(subject: annotation_id, predicate: RDF::Vocab::OA.annotatedBy)
      statement.nil? ? nil : statement.object.value
    end
    
    def annotated_by=(value)
      unless annotated_by.nil?
        @graph.delete({ subject: RDF::URI(annotated_by) })
      end
      @graph.delete({ subject: annotation_id, predicate: RDF::Vocab::OA.annotatedBy })
      unless value.nil?
        @graph.insert_statements([
          RDF::Statement.new(RDF::URI(value), RDF.type, RDF::Vocab::FOAF.Person),
          RDF::Statement.new(annotation_id, RDF::Vocab::OA.annotatedBy, RDF::URI(value))
        ])
      end
    end
    
    def annotated_at
      statement = @graph.first(subject: annotation_id, predicate: RDF::Vocab::OA.annotatedAt)
      statement.nil? ? nil : statement.object.value
    end
    
    def annotated_at=(value)
      @graph.delete({ subject: annotation_id, predicate: RDF::Vocab::OA.annotatedAt })
      @graph << RDF::Statement.new(annotation_id, RDF::Vocab::OA.annotatedAt, value)
    end
    
    def source
      # TODO: Replace this with some way of retrieving the actual source
      statement = @graph.first(subject: target_id, predicate: RDF::Vocab::OA.hasSource)
      statement.nil? ? nil : statement.object.value
    end
    
    def source=(value)
      unless target_id.nil?
        statement = @graph.first(subject: target_id, predicate: RDF::Vocab::OA.hasSource)
        @graph.delete({ subject: statement.object, predicate: RDF.type }) unless statement.nil?
        @graph.delete({ subject: target_id, predicate: RDF::Vocab::OA.hasSource })
      end
      unless value.nil?
        ensure_target!
        @graph.insert_statements([
          RDF::Statement.new(target_id, RDF::Vocab::OA.hasSource, RDF::URI(value.rdf_uri)),
          RDF::Statement.new(RDF::URI(value.rdf_uri), RDF.type, value.rdf_type)
        ])
      end
    end
  end
end
