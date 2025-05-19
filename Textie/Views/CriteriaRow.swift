//
//  CriteriaRow.swift
//  Textie
//
//  Created by 하정우 on 5/19/25.
//

import SwiftUI

struct CriteriaRow: View {
    var criteria: LocalizedStringKey
    var satisfied: Bool
    
    var body: some View {
        HStack {
            Text(criteria)
            Group {
                if satisfied {
                    Image(systemName: "checkmark.circle").foregroundStyle(.green)
                } else {
                    Image(systemName: "xmark.circle").foregroundStyle(.red)
                }
            }
        }
    }
}

#Preview {
    CriteriaRow(criteria: "contains number", satisfied: false)
}
