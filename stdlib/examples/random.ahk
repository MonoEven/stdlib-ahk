#Requires AutoHotkey v2.0

#Include <stdlib\random>

stdlib.random.seed(12345)
random_example_fraction := stdlib.random.random()
random_example_integer := stdlib.random.randint(1, 6)
random_example_choice := stdlib.random.choice(["red", "blue", "green"])
random_example_choices := stdlib.random.choices(["red", "blue", "green"], [1, 2, 3], unset, 4)
random_example_sample := stdlib.random.sample(["red", "blue", "green", "white"], 2)
random_example_values := [1, 2, 3, 4, 5]
random_example_shuffle_result := stdlib.random.shuffle(random_example_values)

try
    stdlib.random.choice(Map("a", 1))
catch KeyError as random_example_mapping_error
    random_example_mapping_key := random_example_mapping_error.Message

class RandomExampleSequence
{
    __Len
    {
        get => 3
    }

    __Item[index]
    {
        get
        {
            if index = 1
                return "a"
            if index = 2
                return "b"
            if index = 3
                return "c"
            throw IndexError("out", -1)
        }
    }
}

stdlib.random.seed(12345)
random_example_sequence_choice := stdlib.random.choice(RandomExampleSequence())
stdlib.random.seed(12345)
random_example_sequence_choices := stdlib.random.choices(RandomExampleSequence(), unset, unset, 4)

try
    stdlib.random.shuffle("ab")
catch TypeError as random_example_string_shuffle_error
    random_example_string_shuffle_message := random_example_string_shuffle_error.Message

try
    stdlib.random.shuffle(stdlib.tuple([1, 2]))
catch TypeError as random_example_tuple_shuffle_error
    random_example_tuple_shuffle_message := random_example_tuple_shuffle_error.Message
