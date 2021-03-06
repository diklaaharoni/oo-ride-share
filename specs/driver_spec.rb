require_relative 'spec_helper'

describe "Driver class" do

  describe "Driver instantiation" do
    before do
      @driver = RideShare::Driver.new(id: 1, name: "George", vin: "33133313331333133")
    end

    it "is an instance of Driver" do
      @driver.must_be_kind_of RideShare::Driver
    end

    it "throws an argument error with a bad ID value" do
      proc{ RideShare::Driver.new(id: 0, name: "George", vin: "33133313331333133")}.must_raise ArgumentError
    end

    it "throws an argument error with a bad VIN value" do
      proc{ RideShare::Driver.new(id: 100, name: "George", vin: "")}.must_raise ArgumentError
      proc{ RideShare::Driver.new(id: 100, name: "George", vin: "33133313331333133extranums")}.must_raise ArgumentError
    end

    it "sets trips to an empty array if not provided" do
      @driver.trips.must_be_kind_of Array
      @driver.trips.length.must_equal 0
    end

    it "is set up for specific attributes and data types" do
      [:id, :name, :vehicle_id, :status].each do |prop|
        @driver.must_respond_to prop
      end

      @driver.id.must_be_kind_of Integer
      @driver.name.must_be_kind_of String
      @driver.vehicle_id.must_be_kind_of String
      @driver.status.must_be_kind_of Symbol
    end
  end

  describe "add trip method" do
    before do
      pass = RideShare::Passenger.new(id: 1, name: "Ada", phone: "412-432-7640")
      @driver = RideShare::Driver.new(id: 3, name: "Lovelace", vin: "12345678912345678")
      @trip = RideShare::Trip.new({id: 8, driver: @driver, passenger: pass, start_time: "2016-08-08T12:14:+300:00", end_time: "2016-08-08T12:14:00+00:00", rating: 5})
    end

    it "throws an argument error if trip is not provided" do
      proc{ @driver.add_trip(1) }.must_raise ArgumentError
    end

    it "increases the trip count by one" do
      previous = @driver.trips.length
      @driver.add_trip(@trip)
      @driver.trips.length.must_equal previous + 1
    end
  end

  describe "average_rating method" do
    before do
      @driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV", vin: "1C9EVBRM0YBC564DZ")
      trip = RideShare::Trip.new({id: 8, driver: @driver, passenger: nil, start_time: "2016-08-08T12:14:+300:00", end_time: "2016-08-08T12:15:00+00:00", rating: 5})
      @driver.add_trip(trip)
    end

    it "returns a float" do
      @driver.average_rating.must_be_kind_of Float
    end

    it "returns a float within range of 1.0 to 5.0" do
      average = @driver.average_rating
      average.must_be :>=, 1.0
      average.must_be :<=, 5.0
    end

    it "returns zero if no trips" do
      driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV", vin: "1C9EVBRM0YBC564DZ")
      driver.average_rating.must_equal 0
    end
  end

  describe "total_revenue" do
    it "must calculate the total revenue for all trips for a given driver" do
      # Test 1: three trips
      trips = [
        RideShare::Trip.new({cost: 5, rating: 3, start_time: "2016-08-08T12:14:+300:00", end_time: "2016-08-08T12:15:00+00:00"}),
        RideShare::Trip.new({cost: 7, rating: 3, start_time: "2016-08-08T12:14:+300:00", end_time: "2016-08-08T12:15:00+00:00"}),
        RideShare::Trip.new({cost: 8, rating: 3, start_time: "2016-08-08T12:14:+300:00", end_time: "2016-08-08T12:15:00+00:00"})
      ]

      driver_data = {
        id: 7,
        vin: 'a' * 17,
        name: 'test driver',
        trips: trips
      }

      driver = RideShare::Driver.new(driver_data)
      driver.total_revenue.must_equal 12.04
    end
  end

  describe "finished_trips" do
    it "return an array of trips that have end time" do
      trips = [
        RideShare::Trip.new({cost: 5, rating: 3, start_time: "2016-08-08T12:14:+300:00", end_time: "2016-08-08T12:15:00+00:00"}),
        RideShare::Trip.new({cost: 7, rating: 3, start_time: "2016-08-08T12:14:+300:00", end_time: "2016-08-08T12:15:00+00:00"}),
        RideShare::Trip.new({cost: 8, rating: 3, start_time: "2016-08-08T12:14:+300:00", end_time: nil})
      ]
      driver_data = {
        id: 7,
        vin: 'a' * 17,
        name: 'test driver',
        trips: trips
      }

      driver = RideShare::Driver.new(driver_data)
      driver.finished_trips.length.must_equal 2
      trips.last.finish_trip!
      driver.finished_trips.length.must_equal 3
    end
  end

  describe "average_revenue" do
    before do
      @driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV", vin: "1C9EVBRM0YBC564DZ")

      start_time = Time.parse('2015-05-20T12:14:00+00:00')
      end_time = start_time + 60 * 60
      trip_data = {
        id: 8,
        driver: @driver,
        passenger: RideShare::Passenger.new(id: 1, name: "Ada", phone: "412-432-7640"),
        start_time: start_time,
        end_time: end_time,
        cost: 23.45,
        rating: 3
      }
      trip_data1 = {
        id: 9,
        driver: @driver,
        passenger: RideShare::Passenger.new(id: 2, name: "Ada", phone: "412-432-7640"),
        start_time: start_time,
        end_time: end_time,
        cost: 43.45,
        rating: 3
      }
      trip = RideShare::Trip.new(trip_data)
      @driver.add_trip(trip)
      trip1= RideShare::Trip.new(trip_data1)
      @driver.add_trip(trip1)
    end

    it "calculate that driver's average revenue per hour spent driving, using the above formula for revenue" do
      @driver.average_revenue.must_equal 25.44
    end

    it "ignore unfinished trips" do
      start_time = Time.parse('2015-05-20T12:14:00+00:00')
      trip_data3 = {
        id: 10,
        driver: @driver,
        passenger: RideShare::Passenger.new(id: 3, name: "Ada", phone: "412-432-7640"),
        start_time: start_time,
        end_time: nil,
        cost: nil,
        rating: nil
      }
      trip = RideShare::Trip.new(trip_data3)
      @driver.add_trip(trip)
      @driver.average_revenue.must_equal 25.44
    end


  end
end
