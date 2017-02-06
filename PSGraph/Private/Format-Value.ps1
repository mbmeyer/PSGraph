function Format-Value
{
    param(
        [string]
        $value,
        [switch]
        $Edge,
        [switch]
        $Node        
    )

    begin
    {
        if($Script:CustomFormat -eq $null)
        {
            Set-NodeFormatScript
        }
    }
    process
    {
        # edges can point to record cells
        if($Edge -and $value -match '(?<node>.*):(?<Record>\w*)')
        {
            # Recursive call to this function to format just the node
            "{0}:{1}" -f (Format-Value $matches.node -Node), $matches.record
        }
        else 
        {
            # Allows for custom node ID formats
            if($Edge -Or $Node)
            {
                $value = @($value).ForEach($Script:CustomFormat)
            }

            switch -Regex ($value)
            {
                # HTML label, special designation
                '^<\s*table.*>.*<\/\s*table\s*>$' {
                    "<$value>"
                }
                # Normal value, no quotes
                '^[\w]+$' {
                    $value
                }
                # Anything else, use quotes
                default {
                    '"{0}"' -f $value
                }
            }
        }
    }
}