using Printf, Statistics

function export_markdown_mcells(filename, results)
    rows = ["2D", "3D"]
    columns= ["compress", "decompress"]
    
    μ_cells = zeros(length(rows), length(columns))
    σ_cells = zeros(length(rows), length(columns))

    μ_bytes = zeros(length(rows), length(columns))
    σ_bytes = zeros(length(rows), length(columns))
    
    for (irow,row) in enumerate(rows), (icolumn,column) in enumerate(columns)
        ncells = results.benchmarkgroup["compression, $row"].tags[1]["ncells"]
        benchmark = results.benchmarkgroup["compression, $row"]["$column, F32"]
        x = (ncells / 1_000_000) ./ (benchmark.times .* 1e-9) # Mega-Cells per second
        μ_cells[irow,icolumn] = mean(x)
        σ_cells[irow,icolumn] = std(x)
        x = (4 * ncells / 1_000_000) ./ (benchmark.times .* 1e-9) # MB per second
        μ_bytes[irow,icolumn] = mean(x)
        σ_bytes[irow,icolumn] = std(x)
    end


    io = open(filename, "w")

    write(io, "# CvxCompress Throughput, Mega-Cells per second\n\n")

    write(io, "|    ")
    for column in columns
        write(io, " | $column")
    end
    write(io, "|\n")
    write(io, "|------")
    for column in columns
        write(io, "| ------ ")
    end
    write(io, "|\n")
    for (irow,row) in enumerate(rows)
        write(io, "| $row")
        for icolumn = 1:length(columns)
            _μ = @sprintf("%.2f", μ_cells[irow,icolumn])
            _σ = @sprintf("%.2f", 100*(σ_cells[irow,icolumn] / μ_cells[irow,icolumn]))
            write(io, " | $_μ MC/s ($_σ %)")
        end
        write(io, "|\n")
    end

    write(io, "# CvxCompress Throughput, MB per second\n\n")

    write(io, "|    ")
    for column in columns
        write(io, " | $column")
    end
    write(io, "|\n")
    write(io, "|------")
    for column in columns
        write(io, "| ------ ")
    end
    write(io, "|\n")
    for (irow,row) in enumerate(rows)
        write(io, "| $row")
        for icolumn = 1:length(columns)
            _μ = @sprintf("%.2f", μ_bytes[irow,icolumn])
            _σ = @sprintf("%.2f", 100*(σ_bytes[irow,icolumn] / μ_bytes[irow,icolumn]))
            write(io, " | $_μ MB/s ($_σ %)")
        end
        write(io, "|\n")
    end

    write(io, """
    ## Julia versioninfo
    ```
    $(results.vinfo)

    Environment Info:
      $(results.benchmarkconfig.env)

    Date:
      $(results.date)
    ```
    """)
    close(io)
end
