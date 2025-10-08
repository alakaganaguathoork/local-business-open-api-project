# Notes

1. AWS pipelines use stored long-lived credentials ($HOME/.aws/credentials).

2. Variables references:

#### Set variable

```bash
echo "##vso[task.setvariable variable=MyVar;]MyValue"
```

#### Reference variable

* Refer to stage dependecy:
  
    ```yaml
    $[ stageDependencies.One.A.outputs['ProduceVar.MyVar'] ]
    ```

* Refer to job dependency:
  
    ```yaml
    $[ dependencies.CompileJob.outputs['CompileJob.CompileVar'] ]
    ```

* Refer to previous step in the same job:

    ```yaml
    $[ steps.CompileStep.outputs['CompileStep.StepVar'] ]
    ```

* Refer to previous step in the same job (alternative syntax):

    ```yaml
    $(CompileStep.StepVar)
    ```

* Refer to previous step in the same job (alternative syntax for bash script):

    ```yaml
    ${CompileStep.StepVar}
    ```

* Refer to variable defined in the same job:

    ```yaml
    $(CompileVar)
    ```

* Refer to variable defined in the same stage:

    ```yaml
    $(StageVar)
    ```
