# Copyright: 2007-2013 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval ::Excel {

    proc Search { worksheetId str { row1 1 } { col1 1 } { row2 -1 } { col2 -1 } } {
        # Find a string in a worksheet cell range.
        #
        # worksheetId - Identifier of the worksheet.
        # str         - Search string.
        # row1        - Row number of upper-left corner of the cell range. 
        # col1        - Column number of upper-left corner of the cell range. 
        # row2        - Row number of lower-right corner of the cell range. 
        # col2        - Column number of lower-right corner of the cell range. 
        #
        # If row2 or col2 is negative, all used rows and columns are searched.
        #
        # Return the first matching cell as a 2-element list {row, col} of indices.
        # If no cell matches the search criteria, an empty list is returned.

        if { $row2 < 0 } {
            set row2 [::Excel::GetNumUsedRows $worksheetId]
        }
        if { $col2 < 0 } {
            set col2 [::Excel::GetNumUsedColumns $worksheetId]
        }

        set matrixList [::Excel::GetMatrixValues $worksheetId $row1 $col1 $row2 $col2] 
        set row 1
        foreach rowList $matrixList {
            set col [lsearch -exact $rowList $str]
            if { $col >= 0 } {
                return [list $row [expr {$col + 1}]]
            }
            incr row
        }
        return [list]
    }

    proc SetHeaderRow { worksheetId headerList { row 1 } { startCol 1 } } {
        # Insert row values from a Tcl list and format as a header row.
        #
        # worksheetId - Identifier of the worksheet.
        # headerList  - List of values to be inserted as header.
        # row         - Row number. Row numbering starts with 1.
        # startCol    - Column number of insertion start. Column numbering starts with 1. 
        #
        # No return value. If headerList is an empty list, an error is thrown.
        #
        # See also: SetRowValues FormatHeaderRow
 
        set len [llength $headerList]
        ::Excel::SetRowValues $worksheetId $row $headerList $startCol $len
        ::Excel::FormatHeaderRow $worksheetId $row $startCol [expr {$startCol + $len -1}]
    }

    proc FormatHeaderRow { worksheetId row startCol endCol } {
        # Format a row as a header row.
        #
        # worksheetId - Identifier of the worksheet.
        # row         - Row number. Row numbering starts with 1.
        # startCol    - Column number of formatting start. Column numbering starts with 1. 
        # endCol      - Column number of formatting end. Column numbering starts with 1. 
        #
        # The cell values of a header are formatted as bold text with both vertical and
        # horizontal centered alignment.
        #
        # No return value.
        #
        # See also: SetHeaderRow

        set header [::Excel::SelectRangeByIndex $worksheetId $row $startCol $row $endCol]
        ::Excel::SetRangeHorizontalAlignment $header $::Excel::xlCenter
        ::Excel::SetRangeVerticalAlignment   $header $::Excel::xlCenter
        ::Excel::SetRangeFontBold $header
        ::Cawt::Destroy $header
    }

    proc ClipboardToMatrix { { sepChar ";" } } {
        # Return the matrix values contained in the clipboard.
        #
        # sepChar - The separation character of the clipboard matrix data.
        #
        # The clipboard data must be in CSV format with sepChar as separation character.
        # See SetMatrixValues for the description of a matrix representation.
        #
        # See also: ClipboardToWorksheet MatrixToClipboard

        set csvFmt [twapi::register_clipboard_format "Csv"]
        while { ! [twapi::clipboard_format_available $csvFmt] } {
            after 10
        }
        twapi::open_clipboard
        set clipboardData [twapi::read_clipboard $csvFmt]
        twapi::close_clipboard

        ::Excel::SetCsvSeparatorChar $sepChar
        set matrixList [::Excel::CsvStringToMatrix $clipboardData]
        return $matrixList
    }

    proc ClipboardToWorksheet { worksheetId { startRow 1 } { startCol 1 } { sepChar ";" } } {
        # Insert the matrix values contained in the clipboard into a worksheet.
        #
        # worksheetId - Identifier of the worksheet.
        # startRow    - Row number. Row numbering starts with 1.
        # startCol    - Column number. Column numbering starts with 1.
        # sepChar     - The separation character of the clipboard matrix data.
        #
        # The insertion of the matrix data starts at cell "startRow,startCol".
        # The clipboard data must be in CSV format with sepChar as separation character.
        # See SetMatrixValues for the description of a matrix representation.
        #
        # No return value.
        #
        # See also: ClipboardToMatrix WorksheetToClipboard

        set matrixList [::Excel::ClipboardToMatrix $sepChar]
        SetMatrixValues $worksheetId $matrixList $startRow $startCol
    }

    proc MatrixToClipboard { matrixList { sepChar ";" } } {
        # Copy a matrix into the clipboard.
        #
        # matrixList - Matrix with table data.
        # sepChar    - The separation character of the clipboard matrix data.
        #
        # The clipboard data will be in CSV format with sepChar as separation character.
        # See SetMatrixValues for the description of a matrix representation.
        #
        # No return value.
        #
        # See also: WorksheetToClipboard ClipboardToMatrix

        set csvFmt [twapi::register_clipboard_format "Csv"]
        twapi::open_clipboard
        twapi::empty_clipboard
        ::Excel::SetCsvSeparatorChar $sepChar
        twapi::write_clipboard $csvFmt [::Excel::MatrixToCsvString $matrixList]
        twapi::close_clipboard
    }

    proc WorksheetToClipboard { worksheetId row1 col1 row2 col2 { sepChar ";" } } {
        # Copy worksheet data into the clipboard.
        #
        # worksheetId - Identifier of the worksheet.
        # row1        - Row number of upper-left corner of the copy range. 
        # col1        - Column number of upper-left corner of the copy range. 
        # row2        - Row number of lower-right corner of the copy range. 
        # col2        - Column number of lower-right corner of the copy range. 
        # sepChar     - The separation character of the clipboard matrix data.
        #
        # The clipboard data will be in CSV format with sepChar as separation character.
        #
        # No return value.
        #
        # See also: ClipboardToWorksheet MatrixToClipboard

        set matrixList [::Excel::GetMatrixValues $worksheetId $row1 $col1 $row2 $col2]
        ::Excel::MatrixToClipboard $matrixList $sepChar
    }
}
