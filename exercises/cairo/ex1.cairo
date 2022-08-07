## Create a function that accepts a parameter and logs it
func log_value(y : felt):      

   ## Start a hint segment that uses python print() 

    %{
        print(ids)
        print(ids.y)
    %}
   ## This exercise has no tests to check against.

   return ()   
end

func main ():
    log_value(5)
    return()
end




