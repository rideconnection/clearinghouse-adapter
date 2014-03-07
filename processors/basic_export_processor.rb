require 'export_processor'
require 'active_support/core_ext/object'
require 'active_support/core_ext/hash'
require 'active_support/time_with_zone'
require 'csv'

# This is working example of an extended ExportProcessor class. To use
# this as the ExportProcessor in your adapter installation, simply 
# update the config/adapter_sync.yml file by specifying the path to this
# file as the export[:processor] value.

# All ExportProcessor instances must impliment a public #process
# method. This method must always accept one argument: an array of trip
# attribute hashes (including nested association attributes). It should
# not return any value. What the method does with the data is dependent
# on the local system and can be customized as neecessary. Some
# examples of what a custom ExportProcessor might do would be to massage
# clearinghouse data into a format that is better suited for the local
# transportation software, or interacting directly with a database
# as opposed to writing to a file.

# In this example, the #process method will write out the exported trip
# data to CSV files: one each for trip tickets, trip claims, trip
# comments and trip results. The data will remain largely unchanged,
# though we will flatten out any array or hstore (hash) attributes into
# individual columns, and any associated address attributes will be
# added as columns on the trip record.

# The Processor::Export::Base class that your ExportProcessor will 
# inherit from includes an initializer which should not be overwritten.
# This initializer is already configured to accept any options that
# your custom processor may need. For instance, in this processor we
# need to specify a folder where the exported files should be saved. 
# Any options you'd like to make available to an instance of the  
# ExportProcessor can specified in the config/adapter_sync.yml file
# under the export[:options] area. You can specify as many options
# as you need for your specific implementation.

# The initializer also instantiates the @logger and @errors instance
# variables. The @logger variable will be a standard logger object that
# you can write log messages to for debugging or informational
# purposes. The @errors variable is an array (initially empty), which
# you can assign any error messages that you would like to be sent to
# system admins when #process is called as part of the AdapterSync
# process.

Time.zone = "UTC"

class ExportProcessor < Processor::Export::Base
  def process(exported_trips)
    export_dir = @options[:export_folder]
    raise RuntimeError, "Export folder not configured, will not export new changes detected on the Clearinghouse" if export_dir.blank?
    raise RuntimeError, "Export folder #{export_dir} does not exist" if Dir[export_dir].empty?

    trip_updates, claim_updates, comment_updates, result_updates = [[], [], [], []]
    exported_trips.each do |trip|
      trip_data = trip.with_indifferent_access
      
      # pluck the modifications to claims, comments, and results out
      # of the trip to report them separately
      claims = trip_data.delete(:trip_claims) || []
      comments = trip_data.delete(:trip_ticket_comments) || []
      result = trip_data.delete(:trip_result) || {}

      # TODO handle any remaining nested objects, such as address
      # fields, array attributes, and hstore attributes
      
      # save results for export
      # make sure the trip_data with the claims, comments, and
      # results removed is not blank or just an ID
      unless trip_data.blank? || trip_data.keys == ['id']
        trip_updates << trip_data
      end
      claims.each { |claim| claim_updates << claim }
      comments.each { |comment| comment_updates << comment }
      result_updates << result unless result.blank?
    end    
    
    # flatten nested structures in the updated trips
    flattened_trips, flattened_claims, flattened_comments, flattened_results = [[], [], [], []]
    trip_updates.each { |x| flattened_trips << flatten_hash(x) }
    claim_updates.each { |x| flattened_claims << flatten_hash(x) }
    comment_updates.each { |x| flattened_comments << flatten_hash(x) }
    result_updates.each { |x| flattened_results << flatten_hash(x) }

    # create combined lists of keys since each change set can include
    # different updated columns
    trip_keys, claim_keys, comment_keys, result_keys = [[], [], [], []]
    flattened_trips.each { |x| trip_keys |= x.stringify_keys.keys }
    flattened_claims.each { |x| claim_keys |= x.stringify_keys.keys }
    flattened_comments.each { |x| comment_keys |= x.stringify_keys.keys }
    flattened_results.each { |x| result_keys |= x.stringify_keys.keys }

    # create file names for exports
    timestamp = timestamp_string
    trip_file = File.join(export_dir, "trip_tickets.#{timestamp}.csv")
    claim_file = File.join(export_dir, "trip_claims.#{timestamp}.csv")
    comment_file = File.join(export_dir, "trip_ticket_comments.#{timestamp}.csv")
    result_file = File.join(export_dir, "trip_results.#{timestamp}.csv")

    # export to CSV
    export_csv(trip_file, trip_keys, flattened_trips)
    export_csv(claim_file, claim_keys, flattened_claims)
    export_csv(comment_file, comment_keys, flattened_comments)
    export_csv(result_file, result_keys, flattened_results)
  end
  
  private
  
  def timestamp_string
    Time.zone.now.strftime("%Y-%m-%d.%H%M%S")
  end
  
  def export_csv(filename, headers, data)
    if data.present?
      CSV.open(filename, 'wb', headers: headers, write_headers: true) do |csv|
        data.each {|result| csv << headers.map { |key| result[key] }}
      end
    end
  end
  
  # flatten a trip's hash structure down to its root level. The data
  # we get from the CH API is predictable enough that we can make 
  # assumptions about the structure. For instance, we shouldn't need
  # to worry about deep nested objects, and we can expect the hash to
  # no more than 2-3 levels deep
  def flatten_hash(hash, prepend_name = nil)
    new_hash = {}
    hash.each do |key, value|
      new_key = [prepend_name, key.to_s].compact.join('_')
      case value
      when Hash
        case key.to_sym
        # Recurs for known nested groups. Note that :address is 
        # under the :originator node, so we catch it after the
        # first round of recursion
        when :customer_address, :pick_up_location, :drop_off_location, :originator, :address
          new_hash.merge!(flatten_hash(value, new_key))
        else
          # Do not recurs otherwise. This is intended for use with 
          # hstore (key/value pair) attributes
          value.each_with_index do |(k,v),i|
            new_hash.merge!({
              "#{new_key}_#{i + 1}_key" => k,
              "#{new_key}_#{i + 1}_value" => v
            })
          end
        end
      when Array
        value.each_with_index do |v,i|
          new_hash.merge!({"#{new_key}_#{i + 1}" => v})
        end
      else
        new_hash[new_key] = value
      end
    end
    new_hash
  end
end