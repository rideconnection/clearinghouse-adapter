# Copyright 2013 Ride Connection
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'test_helper'
require 'support/file_helpers'
require 'hash'
require_relative '../../processors/advanced_processors/advanced_export_processor'

describe ExportProcessor do
  include FileHelpers

  let(:export_folder) { 'tmp/_export_test' }

  let(:options) {{
    export_folder: export_folder,
    mapping_file: 'processors/advanced_processors/sample_data/sample_export_mapping.yml'
  }}

  let(:export_processor) { ExportProcessor.new nil, options }

  let (:trip_result) {{
    "actual_drop_off_time" => "2000-01-01T02:45:00Z",
    "actual_pick_up_time" => "2000-01-01T02:45:00Z",
    "base_fare" => "123.0",
    "billable_mileage" => 123.0,
    "created_at" => "2013-06-27T19:45:08-07:00",
    "driver_id" => "Fred",
    "extra_securement_count" => 123,
    "fare" => "123.0",
    "fare_type" => nil,
    "id" => 1,
    "miles_traveled" => 123.0,
    "odometer_end" => 123.0,
    "odometer_start" => 123.0,
    "outcome" => "Completed",
    "rate" => "123.0",
    "rate_type" => nil,
    "trip_claim_id" => nil,
    "trip_ticket_id" => 11,
    "origin_trip_id" => 1880,
    "updated_at" => "2013-06-27T19:45:08-07:00",
    "vehicle_id" => nil,
    "vehicle_type" => nil
  }}

  let(:trip_ticket_comment) {{
    "body" => "So cool!",
    "created_at" => "2013-04-02T13:06:09-07:00",
    "id" => 6,
    "trip_ticket_id" => 80,
    "origin_trip_id" => 1880,
    "updated_at" => "2013-06-27T17:32:16-07:00",
    "user_id" => 1
  }}

  let (:trip_claim) {{
    "claimant_customer_id" => nil,
    "claimant_provider_id" => 3,
    "claimant_name" => 'Yoohoo',
    "claimant_service_id" => nil,
    "claimant_trip_id" => nil,
    "created_at" => "2013-06-26T11:22:57-07:00",
    "id" => 11,
    "notes" => 'These are notes',
    "proposed_fare" => nil,
    "proposed_pickup_time" => "2013-06-27T17:29:57-07:00",
    "status" => "pending",
    "trip_ticket_id" => 80,
    "origin_trip_id" => 1880,
    "updated_at" => "2013-06-27T17:32:59-07:00"
  }}

  let(:big_ticket_hash) {{
    "id" => 80,
    "status" => "Active",
    "rescinded" => false,
    "origin_provider_id" => 2,
    "origin_customer_id" => "4717",
    "origin_trip_id" => 1880,
    "pick_up_location_id" => nil,
    "drop_off_location_id" => nil,
    "customer_address_id" => 147,
    "customer_first_name" => "Walter",
    "customer_last_name" => "Vasquez",
    "customer_middle_name" => "James",
    "customer_dob" => "1994-07-04",
    "customer_primary_phone" => "825-520-4849",
    "customer_emergency_phone" => nil,
    "customer_primary_language" => nil,
    "customer_ethnicity" => nil,
    "customer_race" => nil,
    "customer_gender" => "M",
    "customer_information_withheld" => true,
    "customer_identifiers" => {
      "a" => "b",
      "c" => "d"
    },
    "customer_notes" => nil,
    "customer_boarding_time" => 0,
    "customer_deboarding_time" => 0,
    "customer_seats_required" => 57,
    "customer_impairment_description" => nil,
    "customer_service_level" => "Wheelchair",
    "customer_mobility_factors" => [
      "a_customer_mobility_factors",
      "b_customer_mobility_factors"
    ],
    "customer_service_animals" => nil,
    "customer_eligibility_factors" => [
      "a_customer_eligibility_factors",
      "b_customer_eligibility_factors"
    ],
    "num_attendants" => 0,
    "num_guests" => 0,
    "requested_pickup_time" => "2000-01-01T19:57:00Z",
    "earliest_pick_up_time" => nil,
    "appointment_time" => "2013-04-26T00:00:00-07:00",
    "requested_drop_off_time" => "2000-01-01T20:59:00Z",
    "allowed_time_variance" => -1,
    "time_window_before" => 10,
    "time_window_after" => 15,
    "trip_purpose_description" => "doctor",
    "trip_funders" => ['ABC', 'XYZ'],
    "trip_notes" => nil,
    "scheduling_priority" => "dropoff",
    "created_at" => "2014-02-18 14:01:20.627780",
    "updated_at" => "2014-03-07 06:29:22.114344",
    "originator" => {
      "id" => 2,
      "name" => "Yahoo",
      "primary_contact_email" => "some@nights.fun",
      "address" => {
        "id" => 2,
        "address_1" => "123 Main St",
        "address_2" => nil,
        "city" => "Portland",
        "position" => nil,
        "state" => "OR",
        "zip" => "97210",
        "created_at" => "2013-03-21T08:03:22-07:00",
        "updated_at" => "2013-03-21T08:03:22-07:00"
      }
    },
    "customer_address" => {
      "id" => 147,
      "address_type" => "Residence",
      "address_1" => "123 Main St",
      "address_2" => nil,
      "city" => "Portland",
      "position" => nil,
      "state" => "OR",
      "zip" => "97210",
      "phone_number" => "(555) 555-5555",
      "common_name" => "Maple Court",
      "jurisdiction" => "county",
      "created_at" => "2014-03-07T06:29:22-08:00",
      "updated_at" => "2014-03-07T06:29:22-08:00"
    },
    "pick_up_location" => nil,
    "drop_off_location" => nil,
    "estimated_distance" => 10,
    "trip_result" => trip_result,
    "trip_claims" => [trip_claim],
    "trip_ticket_comments" => [trip_ticket_comment]
  }}

  let(:trip_to_process) {
    big_tic
  }

  before do
    FileUtils.mkpath export_folder
  end
  
  after do
    remove_test_folders export_folder
  end

  #
  # TEST THE CUSTOM MAPPING FEATURES OF THE ADVANCED EXPORT PROCESSOR
  #
  describe 'advanced export' do
    before do
      # fake timestamp so we can predict the name of output files
      export_processor.stubs(:timestamp_string).returns('timestamp')

      # process test trip
      export_processor.process([big_ticket_hash])

      # read in the output files that were created
      trip_data = read_csv(export_folder, "trip_tickets.timestamp.csv").first
      claim_data = read_csv(export_folder, "trip_claims.timestamp.csv").first
      comment_data = read_csv(export_folder, "trip_ticket_comments.timestamp.csv").first
      result_data = read_csv(export_folder, "trip_results.timestamp.csv").first

      @flattened_trip = HashWithIndifferentAccess[trip_data.headers.zip(trip_data.fields)]
      @flattened_claim = HashWithIndifferentAccess[claim_data.headers.zip(claim_data.fields)]
      @flattened_comment = HashWithIndifferentAccess[comment_data.headers.zip(comment_data.fields)]
      @flattened_result = HashWithIndifferentAccess[result_data.headers.zip(result_data.fields)]
    end

    describe "custom mapping system" do

      describe 'exported trip ticket' do
        EXPECTED_TRIP_MAPPINGS = {
          'clearinghouse_trip_id'             => 'id',
          'trip_id'                           => 'origin_trip_id',
          'provider'                          => [ 'originator', 'name' ],
          'customer_id'                       => 'origin_customer_id',
          'customer_home_address_type'        => [ 'customer_address', 'address_type' ],
          'customer_home_telephone'           => [ 'customer_address', 'phone_number' ],
          'customer_home_common_name'         => [ 'customer_address', 'common_name' ],
          'customer_home_address_1'           => [ 'customer_address', 'address_1' ],
          'customer_home_city'                => [ 'customer_address', 'city' ],
          'customer_home_jurisdiction'        => [ 'customer_address', 'jurisdiction' ],
          'customer_home_state'               => [ 'customer_address', 'state' ],
          'customer_home_zip'                 => [ 'customer_address', 'zip' ],
          'customer_sex'                      => 'customer_gender',
          'customer_load_time'                => 'customer_boarding_time',
          'customer_mobility_requirement'     => 'customer_service_level',
          'requested_drop_off_time'           => 'requested_drop_off_time',
          'early_window'                      => 'time_window_before',
          'late_window'                       => 'time_window_after',
          'timing_preference'                 => 'scheduling_priority',
          'trip_purpose'                      => 'trip_purpose_description',
          'estimated_trip_distance'           => 'estimated_distance'
        }

        EXPECTED_TRIP_MAPPINGS.each do |mapped, original|
          it "maps #{original} to #{mapped}" do
            # only test if the input contained the mapped attribute
            original_value = [original].flatten.inject(big_ticket_hash) {|h, k| h[k] unless h.nil? }
            raise "Test input does not contain a value for #{original}" if original_value.nil?
            @flattened_trip[mapped].must_equal original_value.to_s
          end
        end

        it 'outputs unmapped attributes directly' do
          @flattened_trip['status'].must_equal big_ticket_hash['status']
        end

        # special cases

        it "maps customer_middle_name to customer_middle_initial" do
          @flattened_trip['customer_middle_initial'].must_equal big_ticket_hash['customer_middle_name'].slice(0)
        end

        it "maps customer_identifiers hash to customer_external_id string" do
          @flattened_trip['customer_external_id'].must_equal 'a:b,c:d'
        end

        it "maps customer_eligibility_factors array to customer_eligibility string" do
          @flattened_trip['customer_eligibility'].must_equal 'a_customer_eligibility_factors|b_customer_eligibility_factors'
        end

        it "maps customer_mobility_factors array to customer_assistance_needs string" do
          @flattened_trip['customer_assistance_needs'].must_equal 'a_customer_mobility_factors|b_customer_mobility_factors'
        end

        it "maps trip_funders array to trip_funding_source string" do
          @flattened_trip['trip_funding_source'].must_equal 'ABC|XYZ'
        end
      end

      describe 'exported trip result' do
        EXPECTED_RESULT_MAPPINGS = {
          'clearinghouse_trip_id'             => 'trip_ticket_id',
          'trip_id'                           => 'origin_trip_id',
          'actual_pickup_time'                => 'actual_pick_up_time',
        }

        EXPECTED_RESULT_MAPPINGS.each do |mapped, original|
          it "maps #{original} to #{mapped}" do
            # only test if the input contained the mapped attribute
            original_value = [original].flatten.inject(trip_result) {|h, k| h[k] unless h.nil? }
            raise "Test input does not contain a value for #{original}" if original_value.nil?
            @flattened_result[mapped].must_equal original_value.to_s
          end
        end

        it 'outputs unmapped attributes directly' do
          @flattened_result['outcome'].must_equal trip_result['outcome']
        end
      end

      describe 'exported trip claim' do
        EXPECTED_CLAIM_MAPPINGS = {
          'clearinghouse_trip_id'             => 'trip_ticket_id',
          'trip_id'                           => 'origin_trip_id',
          'claim_notes'                       => 'notes',
          'claiming_provider'                 => 'claimant_name'
        }

        EXPECTED_CLAIM_MAPPINGS.each do |mapped, original|
          it "maps #{original} to #{mapped}" do
            # only test if the input contained the mapped attribute
            original_value = [original].flatten.inject(trip_claim) {|h, k| h[k] unless h.nil? }
            raise "Test input does not contain a value for #{original}" if original_value.nil?
            @flattened_claim[mapped].must_equal original_value.to_s
          end
        end

        it 'outputs unmapped attributes directly' do
          @flattened_claim['status'].must_equal trip_claim['status']
        end
      end
    end

    # basic tests to make sure the advanced processor engages the normalization rules system

    describe "normalization rules" do
      let(:normalization_rules) {{
        trip_ticket: {
          customer_sex: {
            normalizations: { Male: %w(m male man) },
            output_attribute: :gender
          },
          status: {
            normalizations: { foostatus: 'active' }
          }
        },
        trip_result: {
          driver_name: {
            normalizations: { 'Smith' => /sally/i, 'Jones' => /fred/i, 'Adams' => /bob/i },
            output_attribute: :driver_last_name
          }
        }
      }}
      let(:options) {{
        export_folder: export_folder,
        mapping_file: 'processors/advanced_processors/sample_data/sample_export_mapping.yml',
        normalization_rules: normalization_rules
      }}

      it "applies normalization rules to inputs" do
        @flattened_trip['status'].must_equal 'foostatus'
      end

      it "uses mapping outputs as inputs" do
        # sample mapping converts customer_gender to customer_sex
        # then the sample normalization should convert "M" to "Male" and output this as gender
        @flattened_trip['gender'].must_equal 'Male'
      end

      it "operates on models other than just trip tickets" do
        # sample mapping converts driver_id to driver_name
        # sample normalization should converts to last name
        @flattened_result['driver_last_name'].must_equal 'Jones'
      end
    end
  end

  #
  # TESTS EVERYTHING THE BASIC EXPORT PROCESSOR TESTED TO MAKE SURE IT STILL WORKS WITH ADVANCED PROCESSOR
  # TODO: should consider making these shared test examples to DRY up the test code
  #
  describe 'basic export functionality' do
    before do
      # make sure with no mappings that the advanced processor works like the basic processor
      export_processor.mapping.mappings = {}
    end

    describe "#process" do
      it "raises a runtime error if export directory is not configured" do
        export_processor.options[:export_folder] = nil
        Proc.new { export_processor.process([]) }.must_raise(RuntimeError)
      end

      it "raises a runtime error if export directory does not exist" do
        export_processor.options[:export_folder] = 'tmp/__i/__dont/__exist'
        Proc.new { export_processor.process([])}.must_raise(RuntimeError)
      end

      it "exports replicated changes as CSV files" do
        trip_changes = { 'update_type' => 'modified', 'id' => 1, 'customer_first_name' => 'Bob' }
        expected_headers = [ 'update_type', 'id', 'customer_first_name' ]
        export_processor.expects(:export_csv).with(is_a(String), includes(*expected_headers), [trip_changes]).once
        export_processor.stubs(:export_csv).with(is_a(String), [], [])
        export_processor.process [ trip_changes ]
      end

      it "outputs new and modified trip tickets, claims, comments, and results to separate CSV files" do
        export_processor.stubs(:timestamp_string).returns('timestamp')
        export_processor.process([big_ticket_hash])
        File.exist?(File.join(export_folder, "trip_tickets.timestamp.csv")).must_equal true
        File.exist?(File.join(export_folder, "trip_claims.timestamp.csv")).must_equal true
        File.exist?(File.join(export_folder, "trip_ticket_comments.timestamp.csv")).must_equal true
        File.exist?(File.join(export_folder, "trip_results.timestamp.csv")).must_equal true
      end

      describe "attribute values" do
        before do
          export_processor.stubs(:timestamp_string).returns('timestamp')
          export_processor.process([big_ticket_hash])

          csv_data = read_csv(export_folder, "trip_tickets.timestamp.csv")
          csv_row = csv_data.first
          @flattened_hash = HashWithIndifferentAccess[csv_row.headers.zip(csv_row.fields)]
        end

        it "outputs status attribute" do
          @flattened_hash.keys.must_include "status"
          @flattened_hash["status"].must_equal "Active"
        end

        it "flattens location hashes by concatenating the keys together" do
          @flattened_hash.keys.must_include "customer_address_address_1"
          @flattened_hash["customer_address_address_1"].must_equal big_ticket_hash["customer_address"]["address_1"]
        end

        it "flattens originator attributes and originator address attributes by concatenating the keys together" do
          @flattened_hash.keys.must_include "originator_name"
          @flattened_hash["originator_name"].must_equal big_ticket_hash["originator"]["name"]

          @flattened_hash.keys.must_include "originator_address_address_1"
          @flattened_hash["originator_address_address_1"].must_equal big_ticket_hash["originator"]["address"]["address_1"]
        end

        it "flattens array attributes into numbered columns" do
          @flattened_hash.keys.must_include "customer_mobility_factors_1"
          @flattened_hash["customer_mobility_factors_1"].must_equal big_ticket_hash["customer_mobility_factors"][0]

          @flattened_hash.keys.must_include "customer_mobility_factors_2"
          @flattened_hash["customer_mobility_factors_2"].must_equal big_ticket_hash["customer_mobility_factors"][1]
        end

        it "flattens hstore attributes into numbered key and value columns" do
          @flattened_hash.keys.must_include "customer_identifiers_1_key"
          @flattened_hash["customer_identifiers_1_key"].must_equal big_ticket_hash["customer_identifiers"].keys[0]

          @flattened_hash.keys.must_include "customer_identifiers_1_value"
          @flattened_hash["customer_identifiers_1_value"].must_equal big_ticket_hash["customer_identifiers"].values[0]

          @flattened_hash.keys.must_include "customer_identifiers_2_key"
          @flattened_hash["customer_identifiers_2_key"].must_equal big_ticket_hash["customer_identifiers"].keys[1]

          @flattened_hash.keys.must_include "customer_identifiers_2_value"
          @flattened_hash["customer_identifiers_2_value"].must_equal big_ticket_hash["customer_identifiers"].values[1]
        end
      end

      describe "attribute headers" do
        let(:second_big_ticket_hash) { big_ticket_hash.merge({
          "customer_identifiers" => {
            "a" => "b",
          },
          "customer_address" => nil,
          "customer_mobility_factors" => nil,
          "customer_service_animals" => [
            "a_customer_service_animals",
            "b_customer_service_animals"
          ]
        })}

        before do
          export_processor.stubs(:timestamp_string).returns('timestamp')
          export_processor.process([big_ticket_hash, second_big_ticket_hash])

          csv_data = read_csv(export_folder, "trip_tickets.timestamp.csv")

          csv_row = csv_data[0]
          @headers = csv_row.headers
          @first_flattened_hash = HashWithIndifferentAccess[csv_row.headers.zip(csv_row.fields)]

          csv_row = csv_data[1]
          @second_flattened_hash = HashWithIndifferentAccess[csv_row.headers.zip(csv_row.fields)]
        end

        it "creates columns for the largest set of each array attribute, but only populates the cells that are valued for other rows" do
          @headers.must_include "customer_mobility_factors_1"
          @first_flattened_hash["customer_mobility_factors_1"].must_equal big_ticket_hash["customer_mobility_factors"][0]
          @second_flattened_hash["customer_mobility_factors_1"].must_be :blank?

          @headers.must_include "customer_mobility_factors_2"
          @first_flattened_hash["customer_mobility_factors_2"].must_equal big_ticket_hash["customer_mobility_factors"][1]
          @second_flattened_hash["customer_mobility_factors_2"].must_be :blank?

          @headers.must_include "customer_service_animals_1"
          @first_flattened_hash["customer_service_animals_1"].must_be :blank?
          @second_flattened_hash["customer_service_animals_1"].must_equal second_big_ticket_hash["customer_service_animals"][0]

          @headers.must_include "customer_service_animals_2"
          @first_flattened_hash["customer_service_animals_2"].must_be :blank?
          @second_flattened_hash["customer_service_animals_2"].must_equal second_big_ticket_hash["customer_service_animals"][1]
        end

        it "creates key and value columns for the largest set of each hash attribute, but only populates the cells that are valued for other rows" do
          @headers.must_include "customer_identifiers_1_key"
          @first_flattened_hash["customer_identifiers_1_key"].must_equal big_ticket_hash["customer_identifiers"].keys[0]
          @second_flattened_hash["customer_identifiers_1_key"].must_equal second_big_ticket_hash["customer_identifiers"].keys[0]

          @headers.must_include "customer_identifiers_1_value"
          @first_flattened_hash["customer_identifiers_1_value"].must_equal big_ticket_hash["customer_identifiers"].values[0]
          @second_flattened_hash["customer_identifiers_1_value"].must_equal second_big_ticket_hash["customer_identifiers"].values[0]

          @headers.must_include "customer_identifiers_2_key"
          @first_flattened_hash["customer_identifiers_2_key"].must_equal big_ticket_hash["customer_identifiers"].keys[1]
          @second_flattened_hash["customer_identifiers_2_key"].must_be :blank?

          @headers.must_include "customer_identifiers_2_value"
          @first_flattened_hash["customer_identifiers_2_value"].must_equal big_ticket_hash["customer_identifiers"].values[1]
          @second_flattened_hash["customer_identifiers_2_value"].must_be :blank?
        end

        it "creates columns for known hashes (locations, originator), but only populates the cells that are valued for other rows" do
          @headers.must_include "customer_address_address_1"
          @first_flattened_hash["customer_address_address_1"].must_equal big_ticket_hash["customer_address"]["address_1"]
          @second_flattened_hash["customer_address_address_1"].must_be :blank?
        end
      end
    end
  end

end