#!/usr/bin/env ruby
#
#	HtmlGrid -- HyperTextMarkupLanguage Framework
#	Copyright (C) 2003 ywesee - intellectual capital connected
# Andreas Schrafl, Benjamin Fay, Hannes Wyss, Markus Huggler
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#	ywesee - intellectual capital connected, Winterthurerstrasse 52, CH-8006 Zuerich, Switzerland
#	htmlgrid@ywesee.com, www.ywesee.com/htmlgrid
#
# Grid -- htmlgrid -- hwyss@ywesee.com

begin
	require 'htmlgrid.so'
rescue LoadError
	puts "could not find htmlgrid.so, falling back to pure-ruby class"
	module HtmlGrid
		class Grid 
			attr_accessor :width, :height
			private
			class Row
				class Field
					attr_reader :components
					attr_accessor :tag
					ALLOWED_ATTRIBUTES = [
						'align',
						'class',
						'colspan',
						'style',
						'tag',
						'title',
					]
					def initialize
						@components = []
						@attributes = {}
					end
					def add(item)
						if(item.is_a? Array)
							@components += item
						else
							@components.push item
						end
					end
					def add_background
						compose
						@components.each { |component| 
							component.add_background
						}
						if(@attributes["class"])
							@attributes["class"] += "-bg" unless @attributes["class"] =~ /-bg/
						else
							@attributes["class"] = "bg"
						end
					end
					def add_attribute(key, value)
						@attributes.store(key.to_s, value.to_s)
					end
					def add_component_style(style)
						@components.each { |cmp| 
							cmp.set_attribute("class", style) if cmp.respond_to?(:set_attribute)
						}
					end
					def add_style(style)
						@attributes["class"] = style
=begin
						@components.each { |component| 
							component.css = style if component.respond_to?(:css=)
						}
=end
					end
					def colspan
						@attributes.fetch("colspan", 1).to_i
					end
					def colspan=(span)
						@attributes["colspan"] = span.to_s if span.to_i > 1
					end
					def component_html(cgi)
						html = ''
						@components.each { |component| 
							if component.respond_to? :to_html
								html << component.to_html(cgi).to_s
							else
								html << component.to_s
							end
						}
						html = "&nbsp;" if html.empty?
						html
					end
					def compose
						attributes = {}
						@components.each { |component|
							attributes.update(component.attributes) if(component.respond_to?(:attributes))
						}
						attributes.delete_if { |key, value| !ALLOWED_ATTRIBUTES.include? key }
						# FIXME: this is an ugly side_effect
						#attributes.delete("class") unless @attributes["class"].nil?
						@attributes = attributes.update(@attributes)
					end
					def to_html(context)
						compose
						if(@tag && context.respond_to?(@tag))
							context.method(@tag)
						else
							context.method(:td)
						end.call(@attributes) {
							component_html(context)
						}
					end
				end
				def initialize
					@width = 1
					@fields = [Field.new]
					@attributes = {}
				end
				def initialize_row w
					if(w > @width)
						@width.upto(w-1) { |ii| @fields[ii] ||= Field.new }
						@width = w
					end
				end
				def add(item, x)
					(@fields[x] ||= Field.new).add item
				end
=begin
				def add_background(x, w=1)
					each_field(x, w) { |field| 
						field.add_background
					}
				end
				def add_style(style, x, w=1)
					each_field(x, w) { |field| 
						field.add_style(style)
					}
				end
				def add_tag(tag, x, w=1)
					each_field(x, w) { |field| 
						p field
						field.tag = tag
						p field
					}
				end
=end
				def each_field(x, w=1)
					x.upto([x+w, @width].min - 1) { |xx|
						yield(@fields[xx])
					}
				end
				def to_html cgi
					cgi.tr(@attributes) {
						field_html(cgi)
					}
				end
				def field_html(cgi)
					html = ""
					span = 1
					@fields.each { |field|
						if(span < 2)
							html << field.to_html(cgi)
							span = field.colspan
						else
							span.step(-1)
						end
					}
					html
				end
				def [](x)
					begin
						@fields[x]
					rescue StandardError
						nil
					end
				end
			end
			public
			def initialize(attributes={})
				@height = 1
				@width = 1
				@rows = [Row.new]
				@attributes = {
					"cellspacing" =>  "0",
				}.update(attributes)
			end
			def initialize_grid(w, h)
				if(w > @width || h > @height)
					floor = (w > @width) ? 0 : @height
					@width = [w, @width].max
					@height = [h, @height].max
					floor.upto(@height - 1) { |ii|
						(@rows[ii] ||= Row.new).initialize_row(@width)
					}
				end
			end
			def add(arg, x, y, col=false)
				if arg.kind_of? Enumerable
					if(col)
						add_column(arg, x, y)
					else
						add_row(arg, x, y)
					end
				else
					add_field(arg, x, y)
				end
			end
			def add_attribute(key, value, x, y, w=1, h=1)
				each_field(x, y, w, h) { |field|
					field.add_attribute(key, value)
				}
			end
			def add_background(x, y, w=1, h=1)
				each_field(x, y, w, h) { |field| 
					field.add_background(x, w)
				}
			end
			def add_column(arg, x, y)
				offset = 0
				arg.each do |item|
					add_field(item, x, y + offset)
					offset = offset.next
				end
			end
			def add_component_style(style, x, y, w=1, h=1)
				each_field(x, y, w, h) { |field|
					field.add_component_style(style)
				}
			end
			def add_field(arg, x, y)
				initialize_grid(x+1, y+1)
				(@rows[y] ||= Row.new).add(arg, x)
			end
			def add_row(arg, x, y)
				offset = 0
				arg.each do |item|
					add_field(item, x + offset, y)
					offset = offset.next
				end
			end
			def add_style(style, x, y, w=1, h=1)
				each_field(x, y, w, h) { |field|
					field.add_style(style)
				}
			end
			def add_tag(tag, x, y, w=1, h=1)
				initialize_grid(x+w, y+h)
				each_field(x, y, w, h) { |field| 
					field.tag = tag
				}
			end
			def each_field(x, y, w=1, h=1)
				y.upto([y+h, @height].min - 1) { |yy| 
					@rows[yy].each_field(x,w) { |field|
						yield(field)
					}
				}
			end
			def insert_row(y=0, arg=nil)
				@rows[y, 0] = Row.new	
				@height += 1
				add(arg, 0, y)
			end
			def push(arg, x=0, y=height)
				add(arg, x, y)
				set_colspan(x,y)
			end
			def set_attribute(key, value)
				@attributes[key] = value
			end
			def set_attributes(hash)
				@attributes.update(hash)
			end
			def set_colspan(x=0, y=0, span=@width)
				initialize_grid(x+1, y+1)
				self[x,y].colspan = span
			end
			def to_html(cgi)
				cgi.table(@attributes) {
					@rows.collect { |row| row.to_html(cgi) }.join
				}
			end
			def [](x, y)
				begin
					@rows[y][x]
				rescue StandardError
					nil
				end
			end
		end
	end
end