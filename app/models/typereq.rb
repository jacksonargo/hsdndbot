## Tests to determine if a player can add the advanced personality type.
## You have to set a single method that we test (ex. base_value) and a single 
## comparison method (i.e. :==, :>=, etc).
##
## test_collection:
## The method can be run for a collection, or directly on the player.
## If you specificy collection, ex. :plyrskills, then the test will run for
## each model in that collection. The test will return true if it passes for
## ANY of the models in that collection.
##
## test_selection:
## You can restrict which model are tested by setting a match hash
## (ex. {name: "Art"}), and the test will only run against the matched models.
## The matches can be regex's, or you can give an array of matches, in which case,
## all collections for each are tested.
##
## test_method:
## This is required and tells us which method to run to get the value we are
## we are comparing to the target (e.x. :base_value). This can also be an array,
## in which case each method is compared against the target.
##
## comparison_method:
## This is required tells us how to compare the test_method to the target (ex. :==).
## This can be an array, in which case each is used.
##
## target:
## This is required. If test_method.send(comparison_method, target) returns true,
## then the player passes the requirement. The target can be an array, in which case
## each target is used. If the player meets a single target, then the player passes.
##
## For 'OR' functionality, provide arrays in a single typereq. For 'AND' funtionality,
## make multiple typereqs.

class Typereq
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :test_collection   ## Collection of models we will test
  field :test_selection    ## Which models to test
  field :test_method       ## Which method to use for the test
  field :comparison_method ## How we compare the method's result to the target
  field :target            ## What we compare to

  embedded_in :advtype

  ## Test if a player has the requirements
  def player_meets?(player)
    if test_collection.class == Array
      ## Check all the collections
      test_collection.each do |col|
        return true if collection_meets? player.send(col)
      end
      return false
    elsif test_collection
      ## Check the collection
      collection_meets? player.send(test_collection)
    else
      ## Otherwise we just use the player's method
      model_meets? player
    end
  end

  ## Returns true if any models in the collection pass.
  ## Else, returns false
  def collection_meets?(col)
    if test_selection.class == Array
      test_selection.each do |sel|
        return true if selection_meets? col.where(sel)
      end
      return false
    else
      selection_meets? col.where(test_selection)
    end
  end

  def selection_meets? (sel)
    sel.each do |model|
      return true if model_meets? model
    end
    return false
  end

  ## Test if a model meets the reqs
  def model_meets?(model)
    if test_method.class == Array
      test_method.each do |m|
        return true if method_value_meets? model.send(m)
      end
      return false
    else
      method_value_meets? model.send(test_method)
    end
  end

  def method_value_meets? (value)
    if comparison_method.class == Array
      comparison_method.each do |test|
        return true if compare(value, test)
      end
      return false
    else
      compare(value, comparison_method)
    end
  end

  def compare(value, test)
    if target.class == Array
      target.each do |tar|
        return true if value.send(test, tar)
      end
      return false
    else
      value.send(test, target)
    end
  end
end
