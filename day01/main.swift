//  Advent Of Code 2024 - Day 1

import Foundation
import Accelerate

func readInputFile(filePath: String) -> ([Double], [Double])? {
    do {
        // Initialize arrays for left and right lists
        var leftList: [Double] = []
        var rightList: [Double] = []
        
        let content = try String(contentsOfFile: filePath, encoding: .utf8)
        let rows = content.split(separator: "\n")
        
        for row in rows {
            let numbers = row.split(separator: "   ").compactMap { Double($0) }
            if numbers.count == 2 {
                leftList.append(numbers[0])
                rightList.append(numbers[1])
            }
        }
        return (leftList, rightList)
    } catch {
        print("Error reading file: \(error)")
        return nil
    }
}

func part1(leftList: [Double], rightList: [Double]) -> Double {
    var sortedLeftList = leftList
    var sortedRightList = rightList
    
    // Sort both lists
    vDSP_vsortD(&sortedLeftList, vDSP_Length(sortedLeftList.count), 1)
    vDSP_vsortD(&sortedRightList, vDSP_Length(sortedRightList.count), 1)
    
    var differences = [Double](repeating: 0.0, count: sortedLeftList.count)

    // Calculate difference between vectors by element-wise substraction
    vDSP_vsubD(sortedRightList, 1, sortedLeftList, 1, &differences, 1, vDSP_Length(sortedLeftList.count))
    // Avoid negative distances by calculating the absolute value of each element
    vDSP_vabsD(differences, 1, &differences, 1, vDSP_Length(differences.count))

    // Finally, calculate the total distance
    var totalDistance: Double = 0.0
    vDSP_sveD(differences, 1, &totalDistance, vDSP_Length(differences.count))
    
    return totalDistance
}

func part2(leftList: [Double], rightList: [Double]) -> Double {
    // Create a dictionary to count occurrences in the right list
    var rightCountDict = [Double: Double]()
    for num in rightList {
        rightCountDict[num, default: 0] += 1
    }
    // Create an array of counts for the left list based on the right list counts
    let counts = leftList.map { rightCountDict[$0] ?? 0.0 }
    let leftListVector = leftList
    let countsVector = counts
    var products = [Double](repeating: 0.0, count: leftList.count)
    
    // Perform element-wise multiplication: products = leftList * counts
    vDSP_vmulD(leftListVector, 1, countsVector, 1, &products, 1, vDSP_Length(leftList.count))
    
    // Sum the products to get the similarity score
    var similarityScore: Double = 0.0
    vDSP_sveD(products, 1, &similarityScore, vDSP_Length(products.count))
    
    return similarityScore
}

if let input = readInputFile(filePath: "input.txt") {
    let part1Result = part1(leftList: input.0, rightList: input.1)
    let part2Result = part2(leftList: input.0, rightList: input.1)
    print("Part 1: \(part1Result)")
    print("Part 2: \(part2Result)")
}
