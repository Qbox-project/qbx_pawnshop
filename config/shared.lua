return {
    pawnLocation = {
        [1] = {
            coords = vector3(412.34, 314.81, 103.13),
            size = vector3(1.5, 1.8, 2.0),
            heading = 207.0,
            debugPoly = false,
            distance = 3.0
        }
    },
    pawnItems = {
        [1] = {
            item = 'goldchain',
            price = math.random(50, 100)
        },
        [2] = {
            item = 'diamond_ring',
            price = math.random(50, 100)
        },
        [3] = {
            item = 'rolex',
            price = math.random(50, 100)
        },
        [4] = {
            item = '10kgoldchain',
            price = math.random(50, 100)
        },
        [5] = {
            item = 'tablet',
            price = math.random(50, 100)
        },
        [6] = {
            item = 'iphone',
            price = math.random(50, 100)
        },
        [7] = {
            item = 'samsungphone',
            price = math.random(50, 100)
        },
        [8] = {
            item = 'laptop',
            price = math.random(50, 100)
        }
    },
    meltingItems = { -- meltTime is amount of time in minutes per item
        [1] = {
            item = 'goldchain',
            rewards = {
                [1] = {
                    item = 'goldbar',
                    amount = 2
                }
            },
            meltTime = 0.15
        },
        [2] = {
            item = 'diamond_ring',
            rewards = {
                [1] = {
                    item = 'diamond',
                    amount = 1
                },
                [2] = {
                    item = 'goldbar',
                    amount = 1
                }
            },
            meltTime = 0.15
        },
        [3] = {
            item = 'rolex',
            rewards = {
                [1] = {
                    item = 'diamond',
                    amount = 1
                },
                [2] = {
                    item = 'goldbar',
                    amount = 1
                },
                [3] = {
                    item = 'electronickit',
                    amount = 1
                }
            },
            meltTime = 0.15
        },
        [4] = {
            item = '10kgoldchain',
            rewards = {
                [1] = {
                    item = 'diamond',
                    amount = 5
                },
                [2] = {
                    item = 'goldbar',
                    amount = 1
                }
            },
            meltTime = 0.15
        },
    }
}