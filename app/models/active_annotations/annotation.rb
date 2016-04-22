module ActiveAnnotations
  class Annotation < ActiveRecord::Base
    attr :internal
    delegate :start_time, :end_time, 
      :content, :annotated_by, 
      :annotated_at, :source, 
      to: :internal
    
    [:start_time=,:end_time=,:content=,:annotated_by=,:annotated_at=,:source=].each do |setter|
      define_method(setter) do |*args|
        internal.send(setter, *args)
        @internal_changed = true
        self.sync_attributes!
      end
    end
  
    before_save :sync_attributes!
    before_save :sync_annotation!
  
    def inspect
      internal_attrs = [:annotated_by, :annotated_at, :start_time, :end_time, :source, :content].collect { |attr|
        "#{attr}: #{internal.send(attr).inspect}"
      }
      inspection = (["uuid: #{uuid.inspect}"] + internal_attrs).compact.join(", ")
      "#<#{self.class} #{inspection}>"
    end
    
    def sync_attributes!
      self.uuid = internal.annotation_id
      self.source_uri = internal.source
    end
    
    def sync_annotation!
      if @internal_changed
        self.annotation = internal.to_jsonld
        @internal_changed = false
      end
    end

    def internal
      if @internal.nil?
        if self.annotation.nil?
          @internal = RDFAnnotation.new
          self.annotation = @internal.to_jsonld
        else
          @internal = RDFAnnotation.from_jsonld(self.annotation)
        end
      end
      @internal
    end
    
    def annotation
      sync_annotation!
      read_attribute(:annotation)
    end
  end
end
