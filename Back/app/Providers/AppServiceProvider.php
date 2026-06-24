<?php

namespace App\Providers;

use Dedoc\Scramble\Scramble;
use Dedoc\Scramble\Support\Generator\OpenApi;
use Dedoc\Scramble\Support\Generator\RequestBodyObject;
use Dedoc\Scramble\Support\Generator\Schema;
use Dedoc\Scramble\Support\Generator\Types\ObjectType;
use Dedoc\Scramble\Support\Generator\Types\StringType;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Scramble::afterOpenApiGenerated(function (OpenApi $openApi): void {
            foreach ($openApi->paths as $path) {
                if ($path->path !== 'dotations/deliveries/{deliveryId}' || ! isset($path->operations['delete'])) {
                    continue;
                }

                $operation = $path->operations['delete'];
                $operation->parameters = array_values(array_filter(
                    $operation->parameters,
                    fn ($parameter) => ! ($parameter->name === 'motivo_eliminacion' && $parameter->in === 'query'),
                ));

                $schema = Schema::fromType(
                    (new ObjectType)->addProperty('motivo_eliminacion', (new StringType)->setMax(500))
                );

                $operation->addRequestBodyObject(
                    RequestBodyObject::make()
                        ->description('Body opcional para indicar el motivo de eliminacion.')
                        ->setContent('application/json', $schema)
                        ->required(false),
                );
            }
        });
    }
}
