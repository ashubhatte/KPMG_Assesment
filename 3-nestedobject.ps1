function GetValueFromNestedObject {
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable] $object,

        [Parameter(Mandatory = $true)]
        [string] $key
    )

    # Split the key into an array of nested keys
    $keys = $key -split '/'

    # Start with the original object
    $result = $object

    # Traverse the object using the keys
    foreach ($nestedKey in $keys) {
        if ($result.ContainsKey($nestedKey)) {
            $result = $result[$nestedKey]
        } else {
            return $null  # Key not found, return null
        }
    }

    return $result
}