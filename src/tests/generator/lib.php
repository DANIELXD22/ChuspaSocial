<?php

/**
 * Generador de datos de prueba para local_chuspasocial.
 *
 * @package    local_chuspasocial
 * @category   test
 * @copyright  2026 ChuspaSocial
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();

/**
 * Generador de datos de prueba para local_chuspasocial.
 */
class local_chuspasocial_generator extends component_generator_base {

    /** @var int Contador para generar valores únicos por defecto. */
    protected $reportcount = 0;

    /**
     * Crea un reporte usando la clase persistent.
     *
     * @param array $record Valores que sobrescriben los de por defecto.
     * @return \local_chuspasocial\report
     */
    public function create_report(array $record = []): \local_chuspasocial\report {
        $this->reportcount++;
        $i = $this->reportcount;

        if (!isset($record['userid'])) {
            $record['userid'] = $this->datagenerator->create_user()->id;
        }

        $defaults = [
            'postid' => 0,
            'reason' => 'Motivo de prueba ' . $i,
            'status' => 0,
        ];

        $record = array_merge($defaults, $record);

        $report = new \local_chuspasocial\report(0, (object) $record);
        $report->create();

        return $report;
    }
}