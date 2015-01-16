module Sluggable
	extend ActiveSupport::Concern

	included do 
		before_save :generate_slug!
		class_attribute :slug_column
	end

	def generate_slug!
		the_slug = to_slug(self.send(self.class.slug_column.to_sym))
		obj = self.class.find_by slug: the_slug
		count = 2
		while obj && obj != self
			the_slug = append_suffix(the_slug, count)
			obj = self.class.find_by slug: the_slug
			count += 1
		end
		self.slug = the_slug.downcase
	end

	def to_slug(name)
		slug = name.strip
		slug.gsub!(/\s*[^A-Za-z0-9]\s*/, '-')
		slug.gsub!(/-+/, '-')
		slug.downcase
	end

	def append_suffix(slug, count)
		unless slug.split('-').last.to_i == 0
			return slug.split('-').slice(0...-1).join('-') + ('-') + count.to_s
		else
			return slug + '-' + count.to_s
		end
	end

	def to_param
		self.slug
	end

	module ClassMethods
		def sluggable_column(col_name)
			self.slug_column = col_name
		end
	end

end