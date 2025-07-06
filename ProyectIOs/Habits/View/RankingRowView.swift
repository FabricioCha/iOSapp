//
//  RankingRowView.swift
//  ProyectIOs
//
//  Created by Trae AI on 2024.
//

import SwiftUI

struct RankingRowView: View {
    let ranking: RankingEntry
    let position: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Position indicator
            ZStack {
                Circle()
                    .fill(positionColor)
                    .frame(width: 40, height: 40)
                
                if position <= 3 {
                    Image(systemName: positionIcon)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else {
                    Text("\(position)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            // Profile image
            AsyncImage(url: URL(string: ranking.fotoPerfil ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .font(.title)
                    .foregroundColor(Color.appTextSecondary)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                Text(ranking.nombre)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.appTextPrimary)
                
                if let countryCode = ranking.paisCodigo {
                    HStack(spacing: 4) {
                        Text(countryFlag(for: countryCode))
                            .font(.caption)
                        Text(countryCode.uppercased())
                            .font(.caption)
                            .foregroundColor(Color.appTextSecondary)
                    }
                }
            }
            
            Spacer()
            
            // Score
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(ranking.valor)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.appPrimaryAction)
                
                Text("días")
                    .font(.caption)
                    .foregroundColor(Color.appTextSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var positionColor: Color {
        switch position {
        case 1:
            return Color.yellow // Gold
        case 2:
            return Color.gray // Silver
        case 3:
            return Color.orange // Bronze
        default:
            return Color.appPrimaryAction
        }
    }
    
    private var positionIcon: String {
        switch position {
        case 1:
            return "crown.fill"
        case 2:
            return "medal.fill"
        case 3:
            return "medal.fill"
        default:
            return ""
        }
    }
    
    private func countryFlag(for countryCode: String) -> String {
        let base: UInt32 = 127397
        var flag = ""
        for v in countryCode.uppercased().unicodeScalars {
            flag.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return flag
    }
}

#Preview {
    VStack {
        RankingRowView(
            ranking: RankingEntry(
                id: 1,
                nombre: "Juan Pérez",
                fotoPerfil: nil,
                paisCodigo: "MX",
                valor: 45
            ),
            position: 1
        )
        
        RankingRowView(
            ranking: RankingEntry(
                id: 2,
                nombre: "María García",
                fotoPerfil: nil,
                paisCodigo: "ES",
                valor: 38
            ),
            position: 2
        )
        
        RankingRowView(
            ranking: RankingEntry(
                id: 3,
                nombre: "Carlos López",
                fotoPerfil: nil,
                paisCodigo: "AR",
                valor: 32
            ),
            position: 5
        )
    }
    .padding()
    .background(Color.appBackground)
}