## Covid-19 Trend Analysis

This project serves as an example of a self contained analysis project for my 
students. It contains a few files that automatically download available data 
from the John Hopkins repository on Covid-19 (for as long as that's available).
It then constructs a figure that shows the actual numbers and a naive smoother
for delay-adjusted data

### Delay adjustment
The delay adjustment is naive: I just looked for the first day where total
confirmed cases exceeded 100, and used that as "day zero" for every country.
This allows to compare to some minor extent how the epidemic evolves from
the moment a substantial amount of cases is detected in a country

**DISCLAIMER: THIS IS NOT MEANT TO BE SCIENTIFICALLY SOUND. IT IS NOT. DO NOT USE THIS FOR ANY PROPER SCIENTIFIC WORK**

### Origin of the data.

The data comes from the Data Repository by Johns Hopkins CSSE

https://github.com/CSSEGISandData/COVID-19

Thank you very much for this, @CSSEGISandData !
