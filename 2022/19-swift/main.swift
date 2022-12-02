import Foundation
import RegexBuilder

enum Robot: CaseIterable {
    case ore
    case clay
    case obsidian
    case geode
}

struct Recipe {
    var ore: Int = 0
    var clay: Int = 0
    var obsidian: Int = 0
    var geode: Int = 0
}

struct Blueprint {
    let id: Int
    let ore: Recipe
    let clay: Recipe
    let obsidian: Recipe
    let geode: Recipe

    func recipe(of robot: Robot) -> Recipe {
        switch robot {
        case .ore: return ore
        case .clay: return clay
        case .obsidian: return obsidian
        case .geode: return geode
        }
    }
}

struct Robots: Hashable {
    var ore: Int = 0
    var clay: Int = 0
    var obsidian: Int = 0
    var geode: Int = 0

    func count(robot: Robot) -> Int {
        switch robot {
        case .ore: return ore
        case .clay: return clay
        case .obsidian: return obsidian
        case .geode: return geode
        }
    }

    func addRobot(robot: Robot) -> Robots {
        var ore = self.ore
        var clay = self.clay
        var obsidian = self.obsidian
        var geode = self.geode

        switch robot {
        case .ore: ore += 1
        case .clay: clay += 1
        case .obsidian: obsidian += 1
        case .geode: geode += 1
        }
        return Robots(ore: ore, clay: clay, obsidian: obsidian, geode: geode)
    }

    func willOverproduce(byAdding robot: Robot, maxSpend: MaxSpend) -> Bool {
        switch robot {
        case .ore: return ore >= maxSpend.ore
        case .clay: return clay >= maxSpend.clay
        case .obsidian: return obsidian >= maxSpend.obsidian
        case .geode: return false
        }
    }
}

struct Inventory: Hashable {
    var ore: Int = 0
    var clay: Int = 0
    var obsidian: Int = 0
    var geode: Int = 0

    func afford(recipe: Recipe) -> Bool {
        return ore >= recipe.ore
            && clay >= recipe.clay
            && obsidian >= recipe.obsidian
            && geode >= recipe.geode
    }

    func deduct(usingRecipe recipe: Recipe) -> Inventory {
        return Inventory(
            ore: ore - recipe.ore,
            clay: clay - recipe.clay,
            obsidian: obsidian - recipe.obsidian,
            geode: geode - recipe.geode
        )
    }

    func collect(robots: Robots, times: Int = 1) -> Inventory {
        return Inventory(
            ore: ore + robots.ore * times,
            clay: clay + robots.clay * times,
            obsidian: obsidian + robots.obsidian * times,
            geode: geode + robots.geode * times
        )
    }

    func optimize(maxSpend: MaxSpend, time: Int) -> Inventory {
        return Inventory(
            ore: min(ore, maxSpend.ore * time),
            clay: min(clay, maxSpend.clay * time),
            obsidian: min(obsidian, maxSpend.obsidian * time),
            geode: geode
        )
    }
}

struct MaxSpend {
    let ore: Int
    let clay: Int
    let obsidian: Int

    static func using(blueprint: Blueprint) -> MaxSpend {
        let bp = blueprint
        let recipes = [bp.ore, bp.clay, bp.obsidian, bp.geode]
        
        return MaxSpend(
            ore: recipes.map({ $0.ore }).max() ?? 0,
            clay: recipes.map({ $0.clay }).max() ?? 0,
            obsidian: recipes.map({ $0.obsidian }).max() ?? 0
        )
    }
}

struct CacheKey: Hashable {
    let inventory: Inventory
    let robots: Robots
    let timeLeft: Int
}

func parse(input: String) -> [Blueprint] {
    let digitsOnly = Regex {
        TryCapture {
            OneOrMore(.digit)
        } transform: { Int($0) }
    }
    let lines = input.components(separatedBy: "\n")

    var blueprints: [Blueprint] = []
    for line in lines {
        let d = line.matches(of: digitsOnly).map({ $0.output.1 })
        assert(d.count == 7)
        blueprints.append(Blueprint(
            id: d[0],
            ore: Recipe(ore: d[1]),
            clay: Recipe(ore: d[2]),
            obsidian: Recipe(ore: d[3], clay: d[4]),
            geode: Recipe(ore: d[5], obsidian: d[6])
        ))
    }
    return blueprints
}

class Mining {
    let blueprint: Blueprint
    private let maxSpend: MaxSpend
    private var cache: [CacheKey: Int]
    
    init(blueprint: Blueprint) {
        self.blueprint = blueprint
        self.maxSpend = MaxSpend.using(blueprint: blueprint)
        self.cache = [:]
    }
    
    func maxGeodes(in time: Int) -> Int {
        return self.dfs(inventory: Inventory(), robots: Robots(ore: 1), timeLeft: time)
    }
    
    private func shouldBuild(robot: Robot, inventory: Inventory, robots: Robots, timeLeft: Int) -> Bool {
        let recipe = blueprint.recipe(of: robot)

        if robots.willOverproduce(byAdding: robot, maxSpend: maxSpend) {
            return false
        }

        let canBuildBeforeTimeOut = inventory
            .collect(robots: robots, times: timeLeft)
            .afford(recipe: recipe)
        if !canBuildBeforeTimeOut {
            return false
        }

        if robot != .geode && inventory.afford(recipe: blueprint.geode) {
            return false
        }

        return inventory.afford(recipe: recipe)
    }
    
    private func dfs(inventory: Inventory, robots: Robots, timeLeft: Int) -> Int {
        let optimizedInventory = inventory.optimize(maxSpend: maxSpend, time: timeLeft)
        let cacheKey = CacheKey(inventory: optimizedInventory, robots: robots, timeLeft: timeLeft)
        if let cachedValue = cache[cacheKey] {
            return cachedValue
        }

        if timeLeft == 0 {
            cache[cacheKey] = optimizedInventory.geode
            return optimizedInventory.geode
        }

        var geodes: [Int] = []
        for robot in Robot.allCases {
            if shouldBuild(robot: robot, inventory: optimizedInventory, robots: robots, timeLeft: timeLeft) {
                let recipe = blueprint.recipe(of: robot)
                let newInventory = inventory
                    .deduct(usingRecipe: recipe)
                    .collect(robots: robots)
                geodes.append(self.dfs(
                    inventory: newInventory,
                    robots: robots.addRobot(robot: robot),
                    timeLeft: timeLeft - 1
                ))
            }
        }

        let n = self.dfs(
            inventory: inventory.collect(robots: robots),
            robots: robots,
            timeLeft: timeLeft - 1
        )
        geodes.append(n)

        let result = geodes.max() ?? 0
        cache[cacheKey] = result
        return result
    }
}

func solveA(blueprints: [Blueprint]) -> Int {
    return blueprints.map({
        $0.id * Mining(blueprint: $0).maxGeodes(in: 24)
    }).reduce(0, +)
}

func solveB(blueprints: [Blueprint]) -> Int {
    return blueprints[0..<3].map({
        Mining(blueprint: $0).maxGeodes(in: 32)
    }).reduce(1, *)
}


let input = try String(contentsOf: URL(fileURLWithPath: "input.txt"), encoding: .utf8)
let blueprints = parse(input: input)

print(solveA(blueprints: blueprints))
print(solveB(blueprints: blueprints))
