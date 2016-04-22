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
        self.sync_attributes!
      end
    end
  
    before_save :sync_attributes!
    before_save :sync_annotation!
    
    def sync_attributes!
      self.uuid = internal.annotation_id
      self.source_uri = internal.source
    end
    
    def sync_annotation!
      self.annotation = internal.to_jsonld
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
  end
end
